#!/usr/bin/env python
import logging
import argparse
import json
import sys
import os
import subprocess
import lxml.etree as ET
import time
from datetime import datetime

parser = argparse.ArgumentParser(description='Build Packer Template')
parser.add_argument('--debug', dest='debug', help='enable verbose logging', action='store_true')
parser.add_argument('--headless', dest='headless', help='make VMs headless', action='store_true')
parser.add_argument('--skip-build', dest='skip_build', help='skip packer build. For testing only.', action='store_true')
parser.add_argument('--packer', type=str, help='packer binary to use')
parser.add_argument('--varfile', type=str, help='packer var file to use', required=True)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

NSMAP = {'ns0': 'http://www.abiquo.com/appliancemanager/repositoryspace',
      'ns1': 'http://schemas.dmtf.org/ovf/envelope/1',
      'ns2': 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_VirtualSystemSettingData',
      'ns3': 'http://schemas.dmtf.org/wbem/wscim/1/cim-schema/2/CIM_ResourceAllocationSettingData'}

def parse_ovfindex(ovfindex_file, element):
    if os.path.isfile(ovfindex_file):
        parser = ET.XMLParser(remove_blank_text=True)
        xml = ET.parse(ovfindex_file, parser).getroot()

        logger.debug('xml attribs : %s' % element.keys())
        ovf = element.attrib['{http://www.abiquo.com/appliancemanager/repositoryspace}OVFFile']
        logger.debug('ovf is : %s' % ovf)
        current_list = xml.xpath('//ns0:OVFDescription[@ns0:OVFFile="%s"]' % ovf, namespaces=NSMAP)
        if len(current_list) == 0:
            xml.append(element)
        else:
            current = current_list[0]
            logger.debug('Current is : %s' % current)
            xml.replace(current, element)
    else:
        xml = ET.Element("{http://www.abiquo.com/appliancemanager/repositoryspace}RepositorySpace", 
            nsmap=NSMAP)
        xml.set('{http://www.abiquo.com/appliancemanager/repositoryspace}RepositoryName', 'Repository 3.0')
        xml.set('{http://www.abiquo.com/appliancemanager/repositoryspace}RepositoryURI', 'http://s3-eu-west-1.amazonaws.com/abiquo-repository/ovfindex.xml')
        xml.append(element)
    return xml

def build_element(json):
    output_dir = json['output_dir']
    vm_name = json['vm_name']
    ovf_file = "%s/%s/%s.ovf" % (output_dir, vm_name, vm_name)
    product = json_vars['product']
    info = json_vars['info']
    icon = json_vars['icon']

    logger.debug('OVF File is %s' % ovf_file)
    logger.debug('Product is %s' % product)
    logger.debug('Info is %s' % info)
    logger.debug('Icon is %s' % icon)

    built = " Built %s." % datetime.fromtimestamp(os.path.getmtime(ovf_file)).strftime("%Y%m%d")

    info_date = "%s%s" % (info, built)
    xml = ET.Element("{http://www.abiquo.com/appliancemanager/repositoryspace}OVFDescription")
    xml.set('{http://schemas.dmtf.org/ovf/envelope/1}class', 'OS')
    xml.set('{http://schemas.dmtf.org/ovf/envelope/1}instance', '')
    xml.set('{http://www.abiquo.com/appliancemanager/repositoryspace}DiskFormat', 'STREAM_OPTIMIZED')
    xml.set('{http://www.abiquo.com/appliancemanager/repositoryspace}OVFCategories', 'Linux OS')
    xml.set('{http://www.abiquo.com/appliancemanager/repositoryspace}OVFFile', ovf_file)

    info_node = ET.Element('{http://schemas.dmtf.org/ovf/envelope/1}Info')
    info_node.text = info_date
    product_node = ET.Element('{http://schemas.dmtf.org/ovf/envelope/1}Product')
    product_node.text = product
    icon_node = ET.Element('{http://schemas.dmtf.org/ovf/envelope/1}Icon')
    icon_node.set('{http://schemas.dmtf.org/ovf/envelope/1}fileRef', icon)
    icon_node.set('{http://schemas.dmtf.org/ovf/envelope/1}mimeType', 'image/png')
    icon_node.set('{http://schemas.dmtf.org/ovf/envelope/1}width', '200')
    icon_node.set('{http://schemas.dmtf.org/ovf/envelope/1}height', '200')

    xml.append(info_node)
    xml.append(product_node)
    xml.append(icon_node)

    return xml

def getkey(elem):
    return elem.findtext('ns1:Product', namespaces=NSMAP).lower()

def update_index(json_vars):
    output_dir = json_vars['output_dir']
    ovfindex_file = "%s/ovfindex.xml" % output_dir
    
    logger.debug('OVFindex File is %s' % ovfindex_file)
    
    element = build_element(json_vars)
    logger.debug('%s' % ET.tostring(element, pretty_print=True))

    ovfindex_xml = parse_ovfindex(ovfindex_file, element).getroottree()
    logger.debug('%s' % ET.tostring(ovfindex_xml, pretty_print=True))

    parent = ovfindex_xml.getroot()
    logger.debug('Parent : %s' % parent)
    parent[:] = sorted(parent, key=getkey)
    logger.debug('SORRRTEEEED : %s' % parent)
    logger.debug('%s' % ET.tostring(ovfindex_xml, pretty_print=True))

    ovfindex_xml.write(ovfindex_file, pretty_print=True)

if __name__ == "__main__":
    args = parser.parse_args()

    if args.debug:
        logger.setLevel(logging.DEBUG)

    logger.debug('Var file is %s' % args.varfile)
    
    if args.varfile == 'ALL':
        files = os.listdir('vars')
        files = map(lambda x: "vars/%s" % x, files)
    else:
        files = args.varfile.split(',')

    for file in files:
        try:
            logger.info('Loading var file %s' % file)
            with open(file) as vars_file:
                json_vars = json.load(vars_file)
        except:
            logger.error('Could not parse var file', exc_info=True)
            sys.exit(1)

        template_file = json_vars['template']

        outdir = None
        if 'OUTPUT_DIR' in os.environ.keys():
            outdir = os.environ['OUTPUT_DIR']
            json_vars['output_dir'] = outdir
            logger.info('Using output dir %s' % outdir)

        if args.packer:
            packer_cmd = args.packer
        else:
            packer_cmd = 'packer'

        headless = ''
        if args.headless:
            headless = "-var 'headless=true'"

        command = None
        if outdir is None:
            command = "%s build -force -var-file %s %s %s" % (packer_cmd, file, headless, template_file)
        else:
            command = "%s build -force -var-file %s %s -var 'output_dir=%s' %s" % (packer_cmd, file, headless, outdir, template_file)

        logger.info('Packer command to run is : %s' % command)

        if not args.skip_build:
            packerproc = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
            for line in iter(packerproc.stdout.readline, ''):
                logger.info(line.rstrip("\n\r"))
            packerproc.communicate()
            logger.debug('Packer return code was: %i' % packerproc.returncode)

            if packerproc.returncode == 0:
                logger.info("Build successful")
            else:
                logger.error("Build failed!")
                sys.exit(1)
        else:
            logger.debug('Skipping packer build.')

        if 'KEEP_OVF' in os.environ.keys() and os.environ['KEEP_OVF'] == 'true':
            logger.info('Rebuilding ovfindex.xml...')
            update_index(json_vars)
        else:
            logger.info('Not rebuilding ovfindex...')
