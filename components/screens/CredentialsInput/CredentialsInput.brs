sub init()
  m.private = {
    current_input: {
      email: "",
      password: ""
    }
  }

  m.content_helpers = ContentHelpers()
  m.initializers = initializers()
  m.helpers = helpers()

  m.initializers.initChildren(m)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
  ? ">>> " + m.helpers.id(m) + " >>> onKeyEvent"
  ? "press: "; press
  ? "key: "; key

  result = false

  if press
    if key = "down"
      if m.helpers.focusedChild(m) = "Inputs" then m.submit_button.setFocus(true) : result = true
    else if key = "up"
      if m.helpers.focusedChild(m) = "SubmitButton" then m.inputs.setFocus(true) : result = true
    else if key = "back"
      if m.helpers.focusedChild(m) = "InputKeyboard" then m.inputs.setFocus(true) : result = true
    end if

  ' press = false
  '   key event from a child
  else
    if key = "OK"
      if m.helpers.focusedChild(m) = "Inputs"
        m.input_keyboard.type = m.helpers.currentFocusedInput(m)
        m.input_keyboard.visible = true
        m.input_keyboard.setFocus(true)
      else if m.helpers.focusedChild(m) = "InputKeyboard"
        handleInput()
      end if
    else if key = "back"
      ' if m.helpers.focusedChild(m) = "InputKeyboard"
      '   if m.input_keyboard.type = "Email"
      '     current_input =
      '   end if
      '
      '
      ' end if
    end if
  end if

  return result
end function

function onVisibleChange() as void
  if m.top.visible = true then m.input_keyboard.visible = false : m.inputs.setFocus(true)
end function

function setHeader() as void
  m.header_label.text = m.top.header
end function

function handleInput() as void
  m.input_keyboard.setFocus(false)
  m.input_keyboard.visible = false

  input_type = m.input_keyboard.type
  input_value = m.input_keyboard.value

  if input_type = "Email"
    current_input = m.helpers.emailInputNode(m)
  else if input_type = "Password"
    current_input = m.helpers.passwordInputNode(m)
  end if

  current_input.value = input_value
  m.inputs.setFocus(true)
end function

function helpers() as object
  this = {}

  this.id = function(self) as string
    return self.top.id
  end function

  this.focusedChild = function(self) as string
    return self.top.focusedChild.id
  end function

  this.currentFocusedInput = function(self) as string
    index = self.inputs.itemFocused
    return self.inputs.content.getChild(index).getChild(0).title
  end function

  this.emailInputNode = function(self) as object
    return self.inputs.content.getChild(0).getChild(0)
  end function

  this.passwordInputNode = function(self) as object
    return self.inputs.content.getChild(1).getChild(0)
  end function

  this.keyboardValue = function(self) as string
    return self.input_keyboard.value
  end function

  return this
end function

function initializers() as object
  this = {}

  this.initChildren = function(self) as void
    self.top.observeField("visible", "onVisibleChange")

    self.header_label = self.top.findNode("HeaderLabel")
    self.header_label.color = self.global.theme.primary_text_color

    inputs_content = [
      [ { title: "Email", name: "email", value: "" } ],
      [ { title: "Password", name: "password", value: "" } ]
    ]

    self.inputs = self.top.findNode("Inputs")
    self.inputs.focusBitmapUri = self.global.theme.focus_grid_uri
    self.inputs.content = self.content_helpers.twoDimList2ContentNode(inputs_content, "InputNode")

    self.submit_button = self.top.findNode("SubmitButton")
    self.submit_button.focusBitmapUri = self.global.theme.button_focus_uri
    self.submit_button.color = self.global.theme.primary_text_color
    self.submit_button.content = self.content_helpers.oneDimList2ContentNode([{title: "Continue"}], "ButtonNode")

    self.input_keyboard = self.top.findNode("InputKeyboard")
  end function

  return this
end function
