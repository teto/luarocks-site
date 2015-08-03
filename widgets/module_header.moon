
class ModuleHeader extends require "widgets.base"
  @needs: {
    "module"
  }

  admin_panel: =>

  inner_content: =>
    div class: "module_header_inner", ->
      form action: @url_for("follow_module", module_id: @module.id), action: "post", ->
        @csrf_input
        button "Follow"


      if @version
        div class: "top_buttons", ->
          a class: "round_button", href: @url_for(@module), "← Return to module"

      h1 ->
        text @module\name_for_display!
        if @version
          text " "
          span class: "sub", @version.version_name

      if summary = @module.summary
        p class: "module_summary", summary

      @admin_panel!

    div class: "metadata_columns", ->
      div class: "module_header_inner", ->
        div class: "column", ->
          h3 "Uploader"
          user_url = @url_for "user_profile", user: @user.slug
          a href: user_url, -> img class: "avatar", src: @user\gravatar(20)
          a href: user_url, @user.username

        if license = @module\short_license!
          div class: "column", ->
            h3 "License"
            text license

        if url = @module\format_homepage_url!
          div class: "column", ->
            h3 "Homepage"
            a class: "external_url", href: url, @truncate url, 30

        if @version
          div class: "column", ->
            h3 "Version downloads"
            text @format_number @version.downloads
        else
          div class: "column", ->
            h3 "Downloads"
            text @format_number @module.downloads


