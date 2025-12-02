require "test_helper"

describe S3Relay::UploadsHelper do
  before { @product = FactoryGirl.create(:product) }

  describe "#s3_relay_field" do
    describe "without options" do
      it do
        s3_relay_field(@product, :photo_uploads)
          .must_equal %Q{<div class="s3r-container" data-parent-type="product" data-parent-id="#{@product.id}" data-association="photo_uploads" data-disposition=\"inline\" data-acl=\"private\"><input type="file" name="file" id="file" class="s3r-field" /><table class="s3r-upload-list"></table></div>}
      end
    end

    describe "with multiple: true" do
      it do
        s3_relay_field(@product, :photo_uploads, multiple: true)
          .must_equal %Q{<div class="s3r-container" data-parent-type="product" data-parent-id="#{@product.id}" data-association="photo_uploads" data-disposition=\"inline\" data-acl=\"private\"><input type="file" name="file" id="file" multiple="multiple" class="s3r-field" /><table class="s3r-upload-list"></table></div>}
      end
    end

    describe "with disposition: attachment" do
      it do
        s3_relay_field(@product, :photo_uploads, disposition: :attachment)
          .must_equal %Q{<div class="s3r-container" data-parent-type="product" data-parent-id="#{@product.id}" data-association="photo_uploads" data-disposition=\"attachment\" data-acl=\"private\"><input type="file" name="file" id="file" disposition="attachment" class="s3r-field" /><table class="s3r-upload-list"></table></div>}
      end
    end

    describe "with acl: public-read" do
      it do
        s3_relay_field(@product, :photo_uploads, acl: 'public-read')
          .must_equal %Q{<div class="s3r-container" data-parent-type="product" data-parent-id="#{@product.id}" data-association="photo_uploads" data-disposition=\"inline\" data-acl=\"public-read\"><input type="file" name="file" id="file" acl="public-read" class="s3r-field" /><table class="s3r-upload-list"></table></div>}
      end
    end
  end

end
