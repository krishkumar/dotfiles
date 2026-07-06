/* ===========================================================================
   mkdp-copy.js — per-heading "copy whole section" buttons for
   markdown-preview.nvim.

   markdown-preview.nvim renders in a real browser but exposes no JS hook, so
   this file is injected inline into the plugin's out/index.html by the plugin
   spec (see ~/.config/nvim/lua/plugins/markdown.lua). It re-applies on every
   nvim start, so a plugin rebuild that regenerates index.html can't kill it.

   Behaviour: hover a heading -> a clipboard button appears in the left gutter.
   Click it -> everything from that heading down to the next heading of the same
   or higher level is reconstructed back into Markdown and copied. Code fences
   come out verbatim; inline formatting (bold/italic/code/links) is preserved.
   ========================================================================== */
(function () {
  "use strict";

  var HEADINGS = "h1,h2,h3,h4,h5,h6";

  // ---- DOM -> Markdown -----------------------------------------------------

  function level(el) {
    return parseInt(el.tagName.charAt(1), 10);
  }

  // Serialize the inline content of an element to Markdown.
  function inline(node) {
    var out = "";
    node.childNodes.forEach(function (child) {
      if (child.nodeType === 3) {
        out += child.data;
        return;
      }
      if (child.nodeType !== 1) return;
      if (child.classList && child.classList.contains("mkdp-h-copy")) return;
      var tag = child.tagName.toLowerCase();
      switch (tag) {
        case "code":
          out += "`" + child.textContent + "`";
          break;
        case "strong":
        case "b":
          out += "**" + inline(child) + "**";
          break;
        case "em":
        case "i":
          out += "*" + inline(child) + "*";
          break;
        case "del":
        case "s":
          out += "~~" + inline(child) + "~~";
          break;
        case "br":
          out += "\n";
          break;
        case "a":
          out += "[" + inline(child) + "](" + (child.getAttribute("href") || "") + ")";
          break;
        case "img":
          out += "![" + (child.getAttribute("alt") || "") + "](" + (child.getAttribute("src") || "") + ")";
          break;
        default:
          out += inline(child);
      }
    });
    return out;
  }

  function fence(pre) {
    var code = pre.querySelector("code") || pre;
    var lang = "";
    var m = (code.className || "").match(/language-([\w-]+)/);
    if (m) lang = m[1];
    var text = code.textContent.replace(/\n$/, "");
    var ticks = "```";
    while (text.indexOf(ticks) !== -1) ticks += "`"; // avoid closing early
    return ticks + lang + "\n" + text + "\n" + ticks;
  }

  function list(el, indent) {
    var ordered = el.tagName.toLowerCase() === "ol";
    var start = parseInt(el.getAttribute("start") || "1", 10);
    var lines = [];
    var i = 0;
    Array.prototype.forEach.call(el.children, function (li) {
      if (li.tagName.toLowerCase() !== "li") return;
      var marker = ordered ? start + i + ". " : "- ";
      // task list checkbox
      var cb = li.querySelector(":scope > input[type=checkbox]");
      var box = cb ? (cb.checked ? "[x] " : "[ ] ") : "";
      // inline text of the li, excluding nested lists
      var clone = li.cloneNode(true);
      Array.prototype.forEach.call(clone.querySelectorAll("ul,ol"), function (n) {
        n.remove();
      });
      Array.prototype.forEach.call(clone.querySelectorAll("input[type=checkbox]"), function (n) {
        n.remove();
      });
      lines.push(indent + marker + box + inline(clone).trim());
      // nested lists
      Array.prototype.forEach.call(li.children, function (kid) {
        var t = kid.tagName && kid.tagName.toLowerCase();
        if (t === "ul" || t === "ol") lines.push(list(kid, indent + "  "));
      });
      i++;
    });
    return lines.join("\n");
  }

  function table(el) {
    var rows = [];
    Array.prototype.forEach.call(el.querySelectorAll("tr"), function (tr) {
      var cells = Array.prototype.map.call(tr.children, function (c) {
        return inline(c).trim().replace(/\|/g, "\\|");
      });
      rows.push("| " + cells.join(" | ") + " |");
    });
    if (rows.length) {
      var headCells = el.querySelectorAll("thead th, tr:first-child > *").length;
      var sep = "| " + Array(headCells + 1).join("--- |").replace(/ $/, "");
      rows.splice(1, 0, sep.trim());
    }
    return rows.join("\n");
  }

  function block(el) {
    var tag = el.tagName.toLowerCase();
    if (/^h[1-6]$/.test(tag)) return "#".repeat(level(el)) + " " + inline(el).trim();
    if (tag === "p") return inline(el).trim();
    if (tag === "pre") return fence(el);
    if (tag === "ul" || tag === "ol") return list(el, "");
    if (tag === "hr") return "---";
    if (tag === "table") return table(el);
    if (tag === "blockquote") {
      var inner = Array.prototype.map.call(el.children, block).filter(Boolean).join("\n\n");
      return inner.split("\n").map(function (l) { return l ? "> " + l : ">"; }).join("\n");
    }
    return inline(el).trim();
  }

  // Collect [heading .. next same-or-higher heading) and serialize.
  function sectionMarkdown(heading) {
    var lvl = level(heading);
    var blocks = [block(heading)];
    var node = heading.nextElementSibling;
    while (node) {
      if (/^h[1-6]$/i.test(node.tagName) && level(node) <= lvl) break;
      var md = block(node);
      if (md) blocks.push(md);
      node = node.nextElementSibling;
    }
    return blocks.join("\n\n").replace(/\n{3,}/g, "\n\n") + "\n";
  }

  // ---- clipboard + button --------------------------------------------------

  function copy(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }
    return new Promise(function (resolve, reject) {
      try {
        var ta = document.createElement("textarea");
        ta.value = text;
        ta.style.position = "fixed";
        ta.style.opacity = "0";
        document.body.appendChild(ta);
        ta.select();
        document.execCommand("copy");
        document.body.removeChild(ta);
        resolve();
      } catch (e) {
        reject(e);
      }
    });
  }

  var ICON_COPY =
    '<svg viewBox="0 0 16 16" width="14" height="14" aria-hidden="true">' +
    '<path fill="currentColor" d="M4 2a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2h-1v1a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h1V2zm2 0H4a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h5a1 1 0 0 0 1-1v-1H6a2 2 0 0 1-2-2V2zm7 0H6a1 1 0 0 0-1 1v7a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V3a1 1 0 0 0-1-1z"/>' +
    "</svg>";
  var ICON_DONE =
    '<svg viewBox="0 0 16 16" width="14" height="14" aria-hidden="true">' +
    '<path fill="currentColor" d="M13.78 4.22a.75.75 0 0 1 0 1.06l-6.5 6.5a.75.75 0 0 1-1.06 0l-3-3a.75.75 0 1 1 1.06-1.06L6.75 10.19l5.97-5.97a.75.75 0 0 1 1.06 0z"/>' +
    "</svg>";

  function decorate(heading) {
    if (heading.querySelector(":scope > .mkdp-h-copy")) return;
    var btn = document.createElement("button");
    btn.className = "mkdp-h-copy";
    btn.type = "button";
    btn.title = "Copy this section as Markdown";
    btn.setAttribute("aria-label", "Copy this section as Markdown");
    btn.innerHTML = ICON_COPY;
    btn.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopPropagation();
      copy(sectionMarkdown(heading)).then(
        function () {
          btn.innerHTML = ICON_DONE;
          btn.classList.add("copied");
          setTimeout(function () {
            btn.innerHTML = ICON_COPY;
            btn.classList.remove("copied");
          }, 1200);
        },
        function () {
          btn.classList.add("failed");
          setTimeout(function () { btn.classList.remove("failed"); }, 1200);
        }
      );
    });
    heading.insertBefore(btn, heading.firstChild);
  }

  function decorateCode(pre) {
    if (pre.querySelector(":scope > .mkdp-code-copy")) return;
    var btn = document.createElement("button");
    btn.className = "mkdp-code-copy";
    btn.type = "button";
    btn.title = "Copy code";
    btn.setAttribute("aria-label", "Copy code");
    btn.innerHTML = ICON_COPY;
    btn.addEventListener("click", function (e) {
      e.preventDefault();
      e.stopPropagation();
      var code = pre.querySelector("code") || pre;
      copy(code.textContent.replace(/\n$/, "")).then(
        function () {
          btn.innerHTML = ICON_DONE;
          btn.classList.add("copied");
          setTimeout(function () {
            btn.innerHTML = ICON_COPY;
            btn.classList.remove("copied");
          }, 1200);
        },
        function () {
          btn.classList.add("failed");
          setTimeout(function () { btn.classList.remove("failed"); }, 1200);
        }
      );
    });
    pre.appendChild(btn);
  }

  function decorateAll() {
    var body = document.querySelector(".markdown-body");
    if (!body) return;
    body.querySelectorAll(HEADINGS).forEach(decorate);
    body.querySelectorAll("pre").forEach(decorateCode);
  }

  // markdown-preview.nvim re-renders .markdown-body over a websocket on every
  // buffer change, which drops our buttons. Re-decorate on mutation (debounced).
  var pending = null;
  function schedule() {
    if (pending) return;
    pending = setTimeout(function () {
      pending = null;
      decorateAll();
    }, 120);
  }

  function start() {
    decorateAll();
    var target = document.getElementById("page-ctn") || document.body;
    if (target) {
      new MutationObserver(schedule).observe(target, { childList: true, subtree: true });
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start);
  } else {
    start();
  }
})();
