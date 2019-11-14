import css from "../css/app.css"
import "phoenix_html"
import {pick, reduce} from 'lodash'
import {Socket} from 'phoenix'
import getHash from 'md5'

const editor = document.querySelector('[data-editor]')
const id = editor.getAttribute('data-editor')

let socket
let channel

socket = new Socket('/socket', {})
socket.connect()

channel = socket.channel(`editor:${id}`, {})

channel.on('line_change', ({line_number, content}) => {
  const lines = editor.value.split(/\r?\n/)
  lines[line_number - 1] = content  
  setEditorValue(lines)  
})

channel.on('md5_check', ({md5: serverHash}) => {
  const editorHash = getHash(editor.value)
  if (serverHash !== editorHash) {
    channel.push('new_state')
  }
})

channel.on('new_state', ({lines}) => setEditorValue(lines))

channel.join()
  .receive("ok", resp => { 
    console.log("Joined successfully", resp) 
    setEditorValue(resp)
  })
  .receive("error", resp => { console.log("Unable to join", resp) })

function setEditorValue(lines) {
  const start = editor.selectionStart
  const end = editor.selectionEnd
  editor.value = lines.join('\n')
  editor.setSelectionRange(start, end)
}
editor.addEventListener('keydown', function () {
  setTimeout(() => sendValue(), 1)
})

function sendValue() {
  const line_number = editor.value.substr(0, editor.selectionStart).split("\n").length
  const lines = editor.value.split(/\r?\n/)
  channel.push('update', {line_number, content: lines[line_number - 1]})
}