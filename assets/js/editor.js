import { Socket, Presence } from 'phoenix'
import {applyDelta, setContent} from './quill'
import md5 from 'md5'

let socket
let channel

const id = editor.getAttribute('data-editor')

socket = new Socket('/socket', {})
socket.connect()

channel = socket.channel(`editor`, {id})

let presence = new Presence(channel)

const sidebarLink = (path, count) => `
  <div><a class="button ${path === id ? 'button-primary' : ''}" href="/${path}">${path} (${count})</a></div>
`

presence.onSync(() => {
  let editors = {}
  presence.list((_id, {metas: [{current_editor}]}) => {
    const count = editors[current_editor] || 0
    editors[current_editor] = count + 1
  })

  const sidebar = Object.keys(editors).sort().map(x => {
    return sidebarLink(x, editors[x])
  })

  document.getElementById('sidebar').innerHTML = sidebar.join("")
})

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