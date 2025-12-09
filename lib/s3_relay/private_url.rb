require 'addressable/uri'

module S3Relay
  class PrivateUrl < S3Relay::Base

    attr_reader :expires, :path

    def initialize(uuid, file, options={})
      # filename = Addressable::URI.escape(file).gsub("+", "%2B")
      sanitized = sanitize_filename(file)
      filename = Addressable::URI.escape(sanitized)
      @path    = [uuid, filename].join("/")
      @expires = (options[:expires] || 10.minutes.from_now).to_i
    end

    def generate
      "#{public_url}?#{params}"
    end

    def public_url
      "#{endpoint}/#{path}"
    end

    private

    def sanitize_filename(name)
      # Normalizar y remover acentos
      sanitized = name.unicode_normalize(:nfd)
                      .encode('ASCII', replace: '')
      # Reemplazar espacios y caracteres especiales
      sanitized.gsub(/[^a-zA-Z0-9._-]/, '_')
    end

    def params
      [
        "AWSAccessKeyId=#{access_key_id}",
        "Expires=#{expires}",
        "Signature=#{signature}"
      ].join("&")
    end

    def signature
      string = "GET\n\n\n#{expires}\n/#{bucket}/#{path}"
      hmac   = OpenSSL::HMAC.digest(digest, secret_access_key, string)
      CGI.escape(Base64.encode64(hmac).strip)
    end

  end
end
