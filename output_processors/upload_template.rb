require 'abiquo-api'
require 'curb'
require 'logger'

module Abiquo
  module Packer
    class TemplateUploader

      def initialize(opts={})
        unless opts.has_key?("abiquo_api_url") and opts.has_key?("abiquo_username") and opts.has_key?("abiquo_password") and opts.has_key?("datacenter")
          raise "Missing some Abiquo connection parameter!!"
        end
        if opts.has_key?('logger')
          @log = opts.delete('logger') 
        else
          @log = Logger.new(STDOUT)
          @log.level = Logger::INFO
        end

        @abqdata = {
          :abiquo_api_url => opts.delete("abiquo_api_url"),
          :abiquo_username => opts.delete("abiquo_username"),
          :abiquo_password => opts.delete("abiquo_password")
        }
        @abq ||= AbiquoAPI.new(@abqdata)

        repo = find_repo_for(opts.delete("abiquo_datacenter"))
        @datacenter_repo = repo unless repo.nil?

        @opts = opts
      end

      def upload
        template = check_exists
        if template
          # Template exists, update disk
          disk = template.link(:disk0).get
          disk_hash = { 
            "bootable" => true,
            "sequence" => 0,
            "requiredHDInMB" => @opts['disk_size'],
            "diskFileFormat" => "VMDK_SPARSE",
            "virtualMachineTemplateUrl" => template.link(:edit).href,
            "diskUrl" => disk.link(:edit).href,
            "currentPath" => disk.path
          }
          remote_disk = upload_template(template.link(:templatePath).href, disk_hash.to_json, @opts['file'])
          template
        else
          # New template, create and upload.
          template_hash = {
            "name" => @opts['vm_name'],
            "description" => @opts['description'] || @opts['vm_name'],
            "categoryName" => @opts['category'] || "OS",
            "diskFileFormat" => "VMDK_SPARSE",
            "requiredCpu" => @opts['cpu'],
            "requiredHDInMB" => @opts['disk_size'],
            "requiredRamInMB" => @opts['ram'],
            "loginUser" => @opts['user'] || "root",
            "loginPassword" => @opts['password'] || "temporal",
            "osType" => @opts['ostype'] || "#{@opts['vm_name'].match(/\D+/)[0].upcase}_64",
            "osVersion" => @opts['osversion'] || @opts['vm_name'].match(/\d+/)[0],
            "ethernetDriverType" => @opts['nic'] || "VMXNET3"
          }
          template_hash["iconUrl"] = @opts['icon_url'] if @opts['icon_url']
          dest = "#{@datacenter_repo.link(:applianceManagerRepositoryUri).href}/templates"
          remote_disk = upload_template(dest, template_hash.to_json, @opts['file'])

          # Locate template to set additional info
          templates = @datacenter_repo.link(:virtualmachinetemplates).get
          # template = templates.select {|t| remote_disk.include? t.link(:disk0).get.path }.first
          template = templates.select {|t| t.name == template_hash['name'] }.first
          raise "Could not find template after upload!!" if template.nil?

          template.chefEnabled = true
          template.enableCpuHotAdd = true
          template.enableRamHotAdd = true

          template.update
        end
      end

      private

      def find_repo_for(datacenter_name)
        repos = @abq.get(@abq.enterprise).link(:datacenterrepositories).get
        repos.each do |repo|
          if repo.link(:datacenter)
            return repo if repo.link(:datacenter).title.eql? datacenter_name
          end
        end
        nil
      end

      def check_exists
        templates = @datacenter_repo.link(:virtualmachinetemplates).get
        templates.select {|t| t.name.eql? @opts['vm_name'] }.first
      end

      def upload_template(destination, json_template, disk_file)
        c = Curl::Easy.new(destination)
        c.username = @abqdata[:abiquo_username]
        c.password = @abqdata[:abiquo_password]
        c.multipart_form_post = true
        c.ssl_verify_peer = false

        up_size = 0
        c.on_progress do |download_size, downloaded, upload_size, uploaded|
          up_mb = (uploaded / 1024 / 1024).to_i
          size_mb = (upload_size / 1024 / 1024).to_i
          @log.info "Upload progress: #{up_size} MB / #{size_mb} MB" if Time.now.sec == 59 or Time.now.sec == 29 or upload_size == uploaded and upload_size != uploaded and up_mb != up_size
          up_size = up_mb
          true
        end
        c.http_post(Curl::PostField.content('diskInfo', json_template),
                    Curl::PostField.file('diskFile', disk_file))

        http_response, *http_headers = c.header_str.split(/[\r\n]+/).map(&:strip)
        http_headers = Hash[http_headers.flat_map{ |s| s.scan(/^(\S+): (.+)/) }]
        http_headers['Location']
      end
    end
  end
end