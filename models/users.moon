
import Model from require "lapis.db.model"
import generate_key from require "helpers.models"
import slugify from require "lapis.util"

bcrypt = require "bcrypt"

class Users extends Model
  @timestamp: true

  @create: (username, password, email) =>
    encrypted_password = bcrypt.digest password, bcrypt.salt 5
    slug = slugify username

    if @check_unique_constraint "username", username
      return nil, "Username already taken"

    if @check_unique_constraint "slug", slug
      return nil, "Username already taken"

    if @check_unique_constraint "email", email
      return nil, "Email already taken"

    Model.create @, {
      :username, :encrypted_password, :email, :slug
    }

  @login: (username, password) =>
    user = Users\find { :username }
    if user and user\check_password password
      user
    else
      nil, "Incorrect username or password"

  @read_session: (r) =>
    if user_session = r.session.user
      user = @find user_session.id
      if user and user\salt! == user_session.key
        user

  update_password: (pass, r) =>
    @update encrypted_password: bcrypt.digest pass, bcrypt.salt 5
    @write_session r if r

  check_password: (pass) =>
    bcrypt.verify pass, @encrypted_password

  generate_password_reset: =>
    @get_data!
    with token = generate_key 30
      @data\update { password_reset_token: token }

  url_key: (name) => @slug

  write_session: (r) =>
    r.session.user = {
      id: @id
      key: @salt!
    }

  salt: =>
    @encrypted_password\sub 1, 29

  all_modules: =>
    import Modules from require "models"
    Modules\select "where user_id = ?", @id

  is_admin: => @flags == 1

  source_url: (r) => r\build_url "/manifests/#{@slug}"

  get_data: =>
    return if @data
    import UserData from require "models"
    @data = UserData\find(@id) or UserData\create(@id)
    @data

  send_email: (subject, body) =>
    import render_html from require "lapis.html"
    import send_email from require "helpers.email"

    body_html = render_html ->
      div body
      hr!
      h4 ->
        a href: "http://rocks.moonscript.org", "MoonRocks"

    send_email @email, subject, body_html, html: true

  gravatar: (size) =>
    url = "http://www.gravatar.com/avatar/#{ngx.md5 @email}?d=identicon"
    url = url .. "&s=#{size}" if size
    url