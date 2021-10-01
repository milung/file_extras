# Extra file utilities

Prolog module for simplifying some common operation on the file system (e.g. traversing folder structure)

## USAGE

## Exported predicates from the module `file_extras`

### `apply_directory_tree(:Goal, +RootDirectory:atom)` is det
Calls `call(Goal, Arg)` for each file or sub-directory in the 
`RootDirectory` tree, recursively. The scan is the depth-first. 

The argument `Arg` is one of 

* `directory(Directory, Path)`  where `Directory` is name of the directory without 
  the path and `Path` is path (from `RootDirectory`) to the directory itself, 
  including the `Directory` name. If the `Goal` fails then the complete content 
  of the directory is skipped.  
* `file(File, Path)`  where `File` is name of the file without 
  the path and `Path` is path (from `RootDirectory`) to the file itself, 
  including the `File` name. The success or failure of the `Goal` is ignored.

### `fold_directory_tree(:Goal, +RootDirectory:atom, +State0, -StateFinal)` is det
Calls `call(Goal, Arg, StatePrev, StateNext)` for each file or sub-directory in the 
`RootDirectory` tree, recursively. The scan is the depth-first. 

 The argument `Arg` is one of 

* `directory(Directory, Path)`  where `Directory` is name of the directory without 
  the path and `Path` is path (from `RootDirectory`) to the directory itself, 
  including the `Directory` name. If the `Goal` fails then the complete content 
  of the directory is skipped.  
* `file(File, Path)`  where `File` is name of the file without 
  the path and `Path` is path (from `RootDirectory`) to the file itself, 
  including the `File` name. The success or failure of the `Goal` is ignored.

The `State0` is initial state and `StateFinal` is accumulated stated after 
scanning all directories and files for which the `Goal` succeeded. Files in directories
where `Goal` failed for the directory level are skipped. 

### `path_to_posix(+Path:atom, -Posix:atom)` is det
Succeeds if `Posix` unifies with `Path`, given that backslashes in `Path` 
are replaced by forward slashes in `Posix`. Utility for windows paths, seems 
like multiple built-in predicates are sensitive to it. 

## Development

To debug the module, load the `debug.pl` file into prolog top.
