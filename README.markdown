# commentary.vim

Modified version of commentary.vim for fixed width formats. Used for putting 
a comment character in a specific column (I.E. Fortran 77 needs the comment 
character in the first column space). This commenting mode doesn't use 
regular expressions, but instead column specific replacement (for example,
a common Fortran 77 comment character is 'C' in column 1. If the line to be 
commented out is "call subroutine\_a()", then a regex replacement might turn 
"call..." into "all..." instead of putting a 'C' in column 1). Can be activated 
using the variable g:commentary\_fixed. If g:commentary\_fixed is 0 (default), 
the plugin behaves normally.

Comment stuff out.  Use `gcc` to comment out a line (takes a count),
`gc` to comment out the target of a motion (for example, `gcap` to
comment out a paragraph), `gc` in visual mode to comment out the selection,
and `gc` in operator pending mode to target a comment.  You can also use
it as a command, either with a range like `:7,17Commentary`, or as part of a
`:global` invocation like with `:g/TODO/Commentary`. That's it.

I wrote this because 5 years after Vim added support for mapping an
operator, I still couldn't find a commenting plugin that leveraged that
feature (I overlooked
[tcomment.vim](https://github.com/tomtom/tcomment_vim)).  Striving for
minimalism, it weighs in at under 100 lines of code.

Oh, and it uncomments, too.  The above maps actually toggle, and `gcgc`
uncomments a set of adjacent commented lines.

## Installation

If you don't have a preferred installation method, I recommend
installing [pathogen.vim](https://github.com/tpope/vim-pathogen), and
then simply copy and paste:

    cd ~/.vim/bundle
    git clone git://github.com/tpope/vim-commentary.git

Once help tags have been generated, you can view the manual with
`:help commentary`.

## FAQ

> My favorite file type isn't supported!

Relax!  You just have to adjust `'commentstring'`:

    autocmd FileType apache setlocal commentstring=#\ %s

## Self-Promotion

Like commentary.vim? Follow the repository on
[GitHub](https://github.com/tpope/vim-commentary) and vote for it on
[vim.org](http://www.vim.org/scripts/script.php?script_id=3695).  And if
you're feeling especially charitable, follow [tpope](http://tpo.pe/) on
[Twitter](http://twitter.com/tpope) and
[GitHub](https://github.com/tpope).

## License

Copyright (c) Tim Pope.  Distributed under the same terms as Vim itself.
See `:help license`.
