require 'finer_struct'

module FakeAWS
  module S3

    # S3 error information, extracted from:
    #
    # http://docs.aws.amazon.com/AmazonS3/latest/API/ErrorResponses.html
    module ErrorIndex
      class Error < FinerStruct::Immutable(:description, :status_code); end

      def self.error_for_code(error_code)
        errors[error_code] || raise(FakeAWS::UnknownResponseErrorCode)
      end

    private

      def self.errors
        @errors ||= {
          "NoSuchBucket" => Error.new(
            :description => "The specified bucket does not exist.",
            :status_code => 404
          ),
          "NoSuchKey" => Error.new(
            :description => "The specified key does not exist.",
            :status_code => 404
          ),
          "BucketAlreadyExists" => Error.new(
            :description => "The requested bucket name is not available. The bucket namespace is shared by all users of the system. Please select a different name and try again.",
            :status_code => 409
          )
        }
      end
    end

  end
end
