import css from "../css/app.css"
import "phoenix_html"
import {pick} from 'lodash'
import {Socket} from 'phoenix'

let socket
let channel
socket = new Socket('/socket', {})
socket.connect()
channel = socket.channel('editor:generic', {})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on('update', (msg) => {
  console.log(msg)
})

document.addEventListener("keydown", function(e) {
  e.preventDefault();
  console.log(e)
  const keys = ['altKey', 'charCode', 'code', "ctrlKey", "key", "keyCode", "location", "metaKey", "repeat", "shiftKey", "which"]
  channel.push('key_down', pick(e, keys))
}, false);
  