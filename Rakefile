require 'tmpdir'
require 'json'
require 'aws-sdk-v1'

REPO = "git@github.com:dduportal/boot2docker-vagrant-box.git"
BUCKET = "instructure-engineering"
S3_PATH = "vagrant-images/"

task 'default' => 'build-vagrant-box'

task 'build-vagrant-box' do
  s3 = AWS::S3.new.buckets[BUCKET]
  # make sure we have S3 creds, so we don't find out way later
  s3.objects.with_prefix(S3_PATH).count

  Dir.mktmpdir do |dir|
    Dir.chdir(dir)
    system("git clone #{REPO} vagrant-box")
    Dir.chdir("vagrant-box")
    # need a better way to determine version
    File.read("Makefile").match(%r{releases/download/v([\d.]+)/boot2docker})
    box_version = $1
    if box_version.nil?
      raise("couldn't determine the box version from Makefile")
    end
    # remove the parallels build, since I don't have parallels available
    template = JSON.parse(File.read("template.json"))
    template["builders"].delete_if { |builder| builder['type'] == 'parallels-iso' }
    File.open("template.json", "wb") { |f| f.write(JSON.generate(template)) }
    system("make")

    %w[vmware virtualbox].each do |box_type|
      obj_name = "boot2docker_#{box_type}_#{box_version}.box"
      obj = s3.objects[S3_PATH+obj_name]
      obj.write(file: "boot2docker_#{box_type}.box",
                acl: :public_read)
      puts "https://s3.amazonaws.com/#{BUCKET}/#{S3_PATH}#{obj_name}"
    end

    # TODO: update vagrant cloud (aka atlas) automatically
    puts "use the paths above to update vagrant cloud https://vagrantcloud.com/codekitchen/boxes/boot2docker"
  end
end
