import { Socket } from 'phoenix'
import {applyDelta, setContent} from './quill'

let socket
let channel
const id = editor.getAttribute('data-editor')

socket = new Socket('/socket', {})
socket.connect()

channel = socket.channel(`editor:${id}`, {})
  
channel.join().receive("ok", contents => setContent(contents))

channel.on('update', applyDelta)

export function update(msg) {
  channel.push('update', msg)
}