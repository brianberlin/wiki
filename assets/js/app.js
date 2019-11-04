import css from "../css/app.css"
import "phoenix_html"
import {pick, reduce} from 'lodash'
import {Socket} from 'phoenix'

let socket
let channel

socket = new Socket('/socket', {})
socket.connect()

channel = socket.channel('editor:new', {})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

const editor = document.querySelector('[data-editor]')

function process(content) {
  const lines = content.split(/\r?\n/)
  console.log(lines)
}

process(editor.value)

editor.addEventListener('keydown', function () {
  const line_number = editor.value.substr(0, editor.selectionStart).split("\n").length
  const lines = editor.value.split(/\r?\n/)
  channel.push('update', {line_number, content: lines[line_number - 1]})
})

channel.on('content', ({content}) => {
  console.log(content)
})

channel.on('update', ({diff}) => {
  console.log(diff)
})
