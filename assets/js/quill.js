import {update} from './editor'

const Clipboard = Quill.import('modules/clipboard')
const Delta = Quill.import('delta')

class PlainClipboard extends Clipboard {
  convert(html = null) {
    if (typeof html === 'string') {
      this.container.innerHTML = html
    }
    let text = this.container.innerText
    this.container.innerHTML = ''
    return new Delta().insert(text)
  }
}

Quill.register('modules/clipboard', PlainClipboard, true)

const quill = new Quill('#editor', {theme: 'snow'})

quill.on('text-change', function(delta, oldDelta, source) {
  if (source == 'api') {
    console.log("An API call triggered this change.")
  } else if (source == 'user') {
    update({delta})
  }
})

export function applyDelta({delta: {ops}}) {
  const contents = new Delta()
  ops.forEach(({attributes = {}, retain, insert, delete: deleteOp}) => {
    if (retain) {
      contents.retain(retain, attributes)
    } else if (insert) {
      contents.insert(insert, attributes)
    } else if (deleteOp) {
      contents.delete(deleteOp)
    }
  })
  quill.updateContents(contents)
}

export function setContent(contents) {
  quill.setContents(contents)
}