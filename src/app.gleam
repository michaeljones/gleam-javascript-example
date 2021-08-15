import shine.{Html, Node, OnClick, Program, Text}

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
  "../src/shine.js" "intToString"

fn view(model: Model) -> Html(Msg) {
  Node(
    "div",
    [],
    [
      Node("p", [], [Text("Count: "), Text(int_to_string(model.count))]),
      Node("button", [OnClick(Increment)], [Text("Increment")]),
      Node("button", [OnClick(Decrement)], [Text("Decrement")]),
    ],
  )
}

pub fn launch(id: String) -> Nil {
  let program = Program(init, update, view)
  shine.app(id, program)
}
