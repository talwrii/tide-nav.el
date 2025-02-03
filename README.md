# tide-nav.el
Navigate between classes, methods and functions in a TypeScript file in [Emacs](https://www.gnu.org/software/emacs/) with the help of [tide](https://github.com/ananthakumaran/tide).

Show which class, method or function you are in or jump around classes, methods and functions.

## Functions provided
- `tide-nav-which-class` Returns the class that you are in
- `tide-nav-which-function` Returns the method or function that you are in
- `tide-nav-back-class` jumps back to a class

## Blocks
A block is a function a class or a namespaces. If can be useful to ignore the distinctions between these types of object.

- `tide-nav-back-block` jumps to the previous block
- `tide-nav-which-block` returns the nearest block that you are in

## Installing
You could use [straight](https://github.com/radian-software/straight.el) to install the package like so - if you use straight.

```
(straight-use-package '(copilot-hydra :type git :host github :repo "talwrii/tide-nav.el"))
```

Alternatively you can clone this repository with git and add to you emacs [load-path](https://www.gnu.org/software/emacs/manual/html_node/use-package/Load-path.html)

```
(add-to-list 'load-path "~/.emacs.d/tide-nav.el/")
```

## Developing
It isn't that too hard to develop on this repository. You can use `playground.ts` to explore interesting edge cases.

## Alternatives and prior works
I found the "which-class" function in a colleague's public `emacs.d` repository for python and found it quite useful so wanted it in typescript. You might prefer to use a code browser for this sort of navigation.

This is all based around the parsed tree that `tide-command:navbar` provides to emacs lisp.

Some people with use [emacs-lsp](https://github.com/emacs-lsp/lsp-mode) rather than tide for interacting with the TypeScript tree tree. But `tide` is good enough for me.

## About me
I am @readwithai. I make tools related to productivity, [agency](https://readwithai.substack.com/p/reading-and-agency) and [reading](https://readwithai.substack.com/p/what-is-reading-broadly-defined) sometimes using [Obsidian](https://readwithai.substack.com/p/what-exactly-is-obsidian) and [write about](https://readwithai.substack.com/) the topic.

You can follow me on <a href="https://x.com">X</a> or my <a href="https://readwithai.substack.com">blog</a>.

If you find *this* tool useful, you can give me money ($2 ?) of my [kofi](https://ko-fi.com/readwithai)
