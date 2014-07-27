require 'spec_helper'

describe FakeAWS::S3::ObjectStore do
  let(:root_directory)     { "tmp" }
  let(:bucket)             { "mah-bucket" }
  let(:key)                { "/mah-file.txt" }

  subject { described_class.new(root_directory, bucket, key) }

  let(:bucket_path)        { "tmp/mah-bucket" }
  let(:object_file_path)   { "tmp/mah-bucket/mah-file.txt" }
  let(:metadata_file_path) { "tmp/mah-bucket/mah-file.txt.metadata.json" }

  before do
    FileUtils.rm_r(root_directory) rescue Errno::ENOENT
    FileUtils.mkdir_p(bucket_path)
  end

  describe "#bucket" do
    it "returns the bucket" do
      expect(subject.bucket).to eq("mah-bucket")
    end
  end

  describe "#key" do
    it "returns the key" do
      expect(subject.key).to eq("/mah-file.txt")
    end
  end

  describe "#bucket_exists?" do
    it "returns true if the bucket directory exists" do
      expect(subject.bucket_exists?).to be_truthy
    end

    it "returns false if the bucket directory doesn't exist" do
      FileUtils.rmdir(bucket_path)
      expect(subject.bucket_exists?).to be_falsy
    end
  end

  describe "#create_bucket" do
    it "creates the bucket directory" do
      FileUtils.rmdir(bucket_path)
      subject.create_bucket
      expect(Dir.exists?(bucket_path)).to be_truthy
    end
  end

  describe "#object_exists?" do
    it "returns true if the object file exists" do
      File.write(object_file_path, "Hello, world!")
      expect(subject.object_exists?).to be_truthy
    end

    it "returns file if the object file doesn't exist" do
      expect(subject.object_exists?).to be_falsy
    end
  end

  describe "#write_object" do
    it "writes the content to the object file" do
      subject.write_object("Hello, world!", { "bunnies" => "scary" })

      expect(File.read(object_file_path)).to eq("Hello, world!")
    end

    it "writes the metadata to the metadata file as JSON" do
      subject.write_object("Hello, world!", { "bunnies" => "scary" })

      expect(File.read(metadata_file_path)).to eq('{"bunnies":"scary"}')
    end
  end

  describe "#read_object" do
    it "reads the contents of the object file" do
      File.write(object_file_path, "Hello, world!")

      expect(subject.read_object.read).to eq("Hello, world!")
    end
  end

  describe "#read_metadata" do
    it "returns an empty hash if there's no metadata file" do
      expect(subject.read_metadata).to eq({})
    end

    it "returns the JSON from the metadata file converted to a hash" do
      File.write(metadata_file_path, '{"bunnies":"scary"}')

      expect(subject.read_metadata).to eq("bunnies" => "scary")
    end
  end

end

