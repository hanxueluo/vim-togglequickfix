
if exists('g:loaded_togglequickfix') || &cp
    finish
endif
let g:loaded_togglequickfix = 1

function! s:GetBufferList() 
  redir =>buflist 
  silent! ls 
  redir END 
  return buflist 
endfunction

function! s:GetQuickFixBufferNumber()
  let curbufnr = winbufnr(0)
  let l:errBuf = 0
  let l:locBuf = 0
  for line in split(s:GetBufferList(), '\n')
    if line =~ "[Location " 
        let l:locBuf = str2nr(split(line," ")[0])
    elseif line =~ "[Quickfix " 
        let l:errBuf = str2nr(split(line," ")[0])
    endif
  endfor
  return [l:errBuf, l:locBuf]
endfunction

" 0:unmap, 1: map error list, 2:map location list
let g:togglequickfix_key_map = 0

function! s:MapQuickFixKey(isLocBuff)
    if a:isLocBuff
        if g:togglequickfix_key_map != 2
            nmap <silent> <Leader>p :lprev<CR>
            nmap <silent> <Leader>n :lnext<CR>
            let g:togglequickfix_key_map = 2
        endif
    else
        if g:togglequickfix_key_map != 1
            nmap <silent> <Leader>p :cprev<CR>
            nmap <silent> <Leader>n :cnext<CR>
            let g:togglequickfix_key_map = 1
        endif
    endif
endfunction

function! s:ToggleQuickFixWin()
    let l:listBuf = s:GetQuickFixBufferNumber()
    let l:errBuf = l:listBuf[0]
    let l:locBuf = l:listBuf[1]
    let l:curWin = winnr()

    if l:errBuf > 0 && l:locBuf == 0
        cclose
        if len(getloclist(l:curWin)) > 0
            call s:MapQuickFixKey(1)
            lopen
        endif
    elseif l:errBuf > 0 && l:locBuf > 0
        cclose
    elseif l:errBuf == 0 && l:locBuf == 0
        if len(getqflist()) > 0
            call s:MapQuickFixKey(0)
            copen
        elseif len(getloclist(l:curWin)) > 0
            call s:MapQuickFixKey(1)
            lopen
        else
            echo "No Quickfix"
        endif
    elseif l:errBuf == 0 && l:locBuf > 0
        lclose
    endif

    "windo echo winnr().bufname('%')
    if l:curWin != winnr()
        exec "wincmd p"
        "exec curWin."wincmd w"
    endif
endfunction

"TODO: update the key map when user execute "lopen" or "copen" manually.
call <SID>MapQuickFixKey(0)
nmap <script> <silent> <leader>q :call <SID>ToggleQuickFixWin()<CR>
