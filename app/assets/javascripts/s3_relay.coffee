displayFailedUpload = (progressColumn=null) ->
  if progressColumn
    progressColumn.text("File could not be uploaded")
  else
    alert("File could not be uploaded")

publishEvent = (target, name, detail) ->
  $(target).trigger( name, detail )

saveUrl = (container, uuid, filename, contentType, publicUrl, progressColumn, fileColumn) ->
  privateUrl = null

  $.ajax
    type: "POST"
    url: "/s3_relay/uploads"
    data:
      parent_type: container.data("parentType")
      parent_id: container.data("parentId")
      association: container.data("association")
      uuid: uuid
      filename: filename
      content_type: contentType
      public_url: publicUrl
    success: (data, status, xhr) ->
      privateUrl = data.private_url
      if privateUrl == null
        displayFailedUpload(progressColumn)
      else
        fileColumn.html("<a href='#{privateUrl}' target='_blank'>#{filename}</a>")

        virtualAttr = "#{container.data('parentType')}[new_#{container.data('association')}_uuids]"
        hiddenField = "<input type='hidden' name='#{virtualAttr}' value='#{uuid}' />"
        container.append(hiddenField)
      publishEvent(container, "upload:success", [ uuid, filename, privateUrl ])
    error: (xhr) ->
      console.log xhr.responseText

  return privateUrl

uploadFiles = (container) ->
  fileInput = $("input.s3r-field", container)
  files = fileInput.get(0).files
  uploadFile(container, file) for file in files
  fileInput.val("")

uploadFile = (container, file) ->
  fileName = file.name

  # Assign unique value to each request so Safari doesn't consolidate them
  @s3r_upload_index ||= 0
  @s3r_upload_index += 1

  $.ajax
    type: "GET"
    url: "/s3_relay/uploads/new?s3r_upload_index=#{s3r_upload_index}"
    success: (data, status, xhr) ->
      formData = new FormData()
      xhr = new XMLHttpRequest()
      endpoint = data.endpoint
      disposition = container.data("disposition")

      formData.append("AWSAccessKeyID", data.awsaccesskeyid)
      formData.append("x-amz-server-side-encryption", data.x_amz_server_side_encryption)
      formData.append("key", data.key)
      formData.append("success_action_status", data.success_action_status)
      formData.append("acl", data.acl)
      formData.append("policy", data.policy)
      formData.append("signature", data.signature)
      formData.append("content-type", file.type)
      formData.append("content-disposition", "#{disposition}; filename=\"#{fileName}\"")
      formData.append("file", file)

      uuid = data.uuid

      uploadList = $(".s3r-upload-list", container)
      uploadList.prepend("<tr id='#{uuid}'><td><div class='s3r-file-url'>#{fileName}</div></td><td class='s3r-progress'><div class='s3r-bar progress' style='display: none;'><div class='s3r-meter progress-bar progress-bar-striped progress-bar-animated info'></div></div></td></tr>")
      fileColumn = $(".s3r-upload-list ##{uuid} .s3r-file-url", container)
      progressColumn = $(".s3r-upload-list ##{uuid} .s3r-progress", container)
      progressBar = $(".s3r-bar", progressColumn)
      progressMeter = $(".s3r-meter", progressColumn)

      xhr.upload.addEventListener "progress", (ev) ->
        if ev.loaded
          percentage = ((ev.loaded / ev.total) * 100.0).toFixed(0)
          progressBar.show()
          container.parents('form').find(':submit').attr('disabled','disabled');
          progressMeter.css "width", "#{percentage}%"
          if percentage > 10
            progressMeter.html "#{percentage}% &nbsp; "
        else
          progressColumn.text("Subiendo archivo...")  # IE can't get position

      xhr.onreadystatechange = (ev) ->
        if xhr.readyState is 4
          progressMeter.html("Subida Completada &nbsp; ")  # IE can't get position
          progressMeter.removeClass("progress-bar-animated")
          container.parents('form').find(':submit').removeAttr('disabled');

          if xhr.status == 201
            contentType = file.type
            publicUrl = $("Ubicación", xhr.responseXML).text()
            saveUrl(container, uuid, fileName, contentType, publicUrl, progressColumn, fileColumn)
          else
            displayFailedUpload(progressColumn)
            console.log $("Message", xhr.responseXML).text()

      xhr.open "POST", endpoint, true
      xhr.send formData
    error: (xhr) ->
      displayFailedUpload()
      console.log xhr.responseText

jQuery ->

  $(document).on "change", ".s3r-field", ->
    $this = $(this)

    if !!window.FormData
      uploadFiles($this.parent())
    else
      $this.hide()
      $this.parent().append("<p>Your browser can't handle file uploads, please switch to <a href='http://google.com/chrome'>Google Chrome</a>.</p>")
