pub external type VirtualDom

pub type Target {
  IdTarget(String)
  VirtualDomTarget(VirtualDom)
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
  fn(Program(msg, model), msg, model, VirtualDom) -> Nil

external fn render_dom(
  Target,
  Html(msg),
  fn(msg, next_virtual_dom) -> Nil,
) -> Nil =
  "../src/shine.js" "renderDom"

pub fn render(
  target: Target,
  output: Html(msg),
  program: Program(msg, model),
  model: model,
  responder: Responder(msg, model),
) -> Nil {
  render_dom(
    target,
    output,
    fn(msg, next_virtual_dom) {
      responder(program, msg, model, next_virtual_dom)
    },
  )
}

fn respond(
  program: Program(msg, model),
  msg: msg,
  model: model,
  virtual_dom: VirtualDom,
) {
  let model = program.update(msg, model)
  let output = program.view(model)
  render(VirtualDomTarget(virtual_dom), output, program, model, respond)
}

pub fn app(id: String, program: Program(msg, model)) -> Nil {
  // Initial model
  let model = program.init()

  // Initial render
  let output = program.view(model)

  render(IdTarget(id), output, program, model, respond)

  Nil
}
