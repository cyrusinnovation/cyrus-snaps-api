module Rack::Test::Assertions
  RESPONSE_CODES = {
    :ok             => 200,
    :bad_request    => 400,
    :created        => 201,
    :not_authorized => 401,
    :not_found      => 404,
    :redirect       => 302
  }

  def assert_body_contains(expected, message=nil)
    msg = build_message(message, "expected body to contain <?>\n#{last_response.body}", expected)
    assert_block(msg) do
      last_response.body.include?(expected)
    end
  end

  def assert_flash(type=:notice, message=nil)
    msg = build_message(message, "expected <?> flash to exist, but was nil", type.to_s)
    assert_block(msg) do
      last_request.env['rack.session']['flash']
    end
  end

  def assert_flash_message(expected, type=:notice, message=nil)
    assert_flash(type, message)
    flash = last_request.env['rack.session']['flash'][type.to_s]
    msg = build_message(message, "expected flash to be <?> but was <?>", expected, flash)
    assert_block(msg) do
      expected == flash
    end
  end

  def assert_response(expected, message=nil)
    status = last_response.status
    msg = build_message(
      message,
      "expected last response to be <?> but was <?>",
      "#{RESPONSE_CODES[expected]}:#{expected}",
      "#{status}:#{RESPONSE_CODES.key(status)}"
    )

    assert_block(msg) do
      status == RESPONSE_CODES[expected]
    end
  end

  def assert_redirected_to(expected, msg=nil)
    assert_response(:redirect)
    actual = URI(last_response.location).path
    msg = build_message(message, "expected to be redirected to <?> but was <?>", expected, actual)

    assert_block(msg) do
      expected == actual
    end
  end

  def assert_content_type(expected, message=nil)
    actual_content_type = last_response.content_type.split(';')[0]
    msg = build_message(
      message,
      "expected content type to be <?> but was <?>",
      expected,
      actual_content_type
    )

    assert_block(msg) do
      Rack::Mime.mime_type(".#{expected}") == actual_content_type
    end
  end
end
