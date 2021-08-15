pub type Dom {
  Dom
}

pub type Html(msg) {
  Node(
    node: String,
    attributes: List(Attribute(msg)),
    children: List(Html(msg)),
  )
  Text(String)
}

pub type Attribute(msg) {
  OnClick(msg)
}

pub type Program(msg, model) {
  Program(
    init: fn() -> model,
    update: fn(msg, model) -> model,
    view: fn(model) -> Html(msg),
  )
}

type Responder(msg, model) =
  fn(String, Program(msg, model), msg, model) -> Nil

external fn render_dom(String, Html(msg), fn(msg) -> Nil) -> Nil =
  "../src/shine.js" "render_dom"

pub fn render(
  id: String,
  output: Html(msg),
  program: Program(msg, model),
  model: model,
  responder: Responder(msg, model),
) -> Nil {
  render_dom(id, output, fn(msg) { responder(id, program, msg, model) })
}

fn respond(id: String, program: Program(msg, model), msg: msg, model: model) {
  let model = program.update(msg, model)
  let output = program.view(model)
  render(id, output, program, model, respond)
}

pub fn app(id: String, program: Program(msg, model)) -> Nil {
  // Initial model
  let model = program.init()

  // Initial render
  let output = program.view(model)

  render(id, output, program, model, respond)

  Nil
}

// User code
pub type Model {
  Model(count: Int)
}

pub type Msg {
  Increment
  Decrement
}

fn init() -> Model {
  Model(count: 1)
}

fn update(msg: Msg, model: Model) -> Model {
  case msg {
    Increment -> Model(model.count + 1)
    Decrement -> Model(model.count - 1)
  }
}

external fn int_to_string(Int) -> String =
  "../src/shine.js" "int_to_string"

fn view(model: Model) -> Html(Msg) {
  Node(
    "div",
    [],
    [
      Node( "p", [], [Text("Count: "), Text(int_to_string(model.count))],),
      Node("button", [OnClick(Increment)], [Text("Increment")]),
      Node("button", [OnClick(Decrement)], [Text("Decrement")]),
    ],
  )
}

pub fn launch(id: String) -> Nil {
  let program = Program(init, update, view)

  app(id, program)
}
