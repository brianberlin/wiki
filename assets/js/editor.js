import { Socket } from 'phoenix'
import {applyDelta, setContent} from './quill'
import md5 from 'md5'

let socket
let channel
const id = editor.getAttribute('data-editor')

socket = new Socket('/socket', {})
socket.connect()

channel = socket.channel(`editor:${id}`, {})
  
channel.join().receive("ok", contents => setContent(contents))

channel.on('update', applyDelta)
channel.on('clean', setContent)

export function update(msg) {
  channel.push('update', msg)
}

export function check({ops}) {
  const lastOp = ops.pop()
  const hash = md5(JSON.stringify({ops: [...ops, {insert: lastOp.insert.trim()}]}))
  channel.push('md5', hash)
}