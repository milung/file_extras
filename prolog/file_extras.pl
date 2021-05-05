:- module(file_extras, [
    apply_directory_tree/2,     % :Goal, +RootDirectory:atom
    fold_directory_tree/4,      % :Goal, +RootDirectory:atom, +State0, -StateFinal
    path_to_posix/2             % +Path:atom, -Posix:atom
]).
%! <module> file_extras add on predicates to file system operations


:- meta_predicate 
    apply_directory_tree(1, +),
    fold_directory_tree(3, +, +, -).

:- multifile
    mime:mime_extension/2.

%%% PUBLIC PREDICATES %%%%%%%%%%%%%%%%%%%%%%%%%%

%! apply_directory_tree(:Goal, +RootDirectory:atom) is det
%  Calls `call(Goal, Arg)` for each file or sub-directory in the 
% `RootDirectory` tree, recursively. The scan is the depth-first. 
%
%  The argument `Arg` is one of 
% 
% * `directory(Directory, Path)`  where `Directory` is name of the directory without 
%   the path and `Path` is path (from `RootDirectory`) to the directory itself, 
%   including the `Directory` name. If the `Goal` fails then the complete content 
%   of the directory is skipped.  
% * `file(File, Path)`  where `File` is name of the file without 
%   the path and `Path` is path (from `RootDirectory`) to the file itself, 
%   including the `File` name. The success or failure of the `Goal` is ignored.
apply_directory_tree(Goal, Root) :-    
    directory_file_path(Parent, Dir, Root),
    apply_directory_tree(
        [Arg, State, State] >> call(Goal, Arg),
        Parent,
        [Dir], _, _).
%! fold_directory_tree(:Goal, +RootDirectory:atom, +State0, -StateFinal) is det
%  Calls `call(Goal, Arg, StatePrev, StateNext)` for each file or sub-directory in the 
% `RootDirectory` tree, recursively. The scan is the depth-first. 
%
%  The argument `Arg` is one of 
% 
% * `directory(Directory, Path)`  where `Directory` is name of the directory without 
%   the path and `Path` is path (from `RootDirectory`) to the directory itself, 
%   including the `Directory` name. If the `Goal` fails then the complete content 
%   of the directory is skipped.  
% * `file(File, Path)`  where `File` is name of the file without 
%   the path and `Path` is path (from `RootDirectory`) to the file itself, 
%   including the `File` name. The success or failure of the `Goal` is ignored.
%
%  The `State0` is initial state and `StateFinal` is accumulated stated after 
%  scanning all directories and files for which the `Goal` succeeded. Files in directories
%  where `Goal` failed for the directory level are skipped. 
fold_directory_tree(Goal, Root, State0, StateFinal) :-    
    directory_file_path(Parent, Dir, Root),
    apply_directory_tree(Goal, Parent, [Dir], State0, StateFinal).

%! path_to_posix(+Path:atom, -Posix:atom) is det
%  Succeeds if `Posix` unifies with `Path`, given that backslashes in `Path` 
%  are replaced by forward slashes in `Posix`. Utility for windows paths, seems 
%  like multiple built-in predicates are sensitive to it. 
path_to_posix(Path, Posix) :-
    atomic_list_concat(Segments, '\\', Path),
    atomic_list_concat(Segments, '/', Posix).


%%% PRIVATE PREDICATES %%%%%%%%%%%%%%%%%%%%%%%%%

apply_directory_tree(_, _, [], State, State) :- !.
 apply_directory_tree(Goal, Parent, [Dir| SameLevel], State0, StateFinal) :-    
    directory_file_path(Parent, Dir, Path),
    exists_directory(Path),
    (   call(Goal, directory(Dir, Path), State0, State1)
    ->  directory_files(Path, Entries),
        exclude([D] >> memberchk(D, ['.','..']), Entries, Entries1),  
        !,
        apply_directory_tree(Goal, Path, Entries1, State1, State2)
    ;   true
    ),
    !,
    apply_directory_tree(Goal, Parent, SameLevel, State2, StateFinal),
    !.
 apply_directory_tree(Goal, Parent, [File| SameLevel], State0, StateFinal) :-    
    directory_file_path(Parent, File, Path),
    exists_file(Path),
    ignore(call(Goal, file(File, Path), State0, State1)),
    apply_directory_tree(Goal, Parent, SameLevel, State1, StateFinal),
    !.

mime:mime_extension(rtf, 'application/rtf').