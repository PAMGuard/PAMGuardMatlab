# Contributing Guidelines

PAMGuardMatlab is an open-source project. Whilst out license does not require it, we welcome you to contribute any changes you make back to the original repository.

## Getting Started

If you're planning on making contributions to PAMGuardMatlab, we highly recommend that you fork the repository, and then clone it into your machine. In the MATLAB editor, on the left sidebar, click on the 'Project' button then select [pgmatlab.prj](pgmatlab.prj) in the root of your cloned repository. This will automatically set-up the development environment, including the MATLAB path.

## Testing

There is a comprehensive testing suite located in the [tests](tests) folder. To run these tests, run the following commands.

```commandline
cd tests;
runtests;
```

If you add new functionality to PAMGuardMatlab, please ensure you write appropriate unit tests in the testing suite. 

> If you find that the changes you have made are failing existing tests (due to an existing bug in the program or the testing suite), you are welcome to change the testing suite.

## Making a Pull Request

Once you are satisfied with your tested changes, you should make a pull request, linking an issue and with a detailed commit history (if there is one), changelog, and details and any new tests written. 

The GitHub repository will automatically run the unit tests in MacOS, Linux, and Windows - and you can see this by viewing your pull request.

## Creating a New Release

Stable code is maintained through new releases. This allows users to download a lightweight copy of the code without development tools such as tests.

Upon the creation of a release, the following CI action is executed (allow 30-60 seconds for this to complete):

- The user-facing code (README.md, LICENCE, src/*) is put in an archive and attached to the release.

Releases should be semantically named and tagged like so. These tags are dynamically inserted in the tarball and wheel uploaded to PyPI.

- V1.2.3
  - Tag: v1.2.3
- V1.2.3 Beta 1
  - Tag: v1.2.3-b1
- V1.2.3 Alpha 1
  - Tag: v1.2.3-a1

## Structure

All the source code is found in the [src/+pgmatlab](src/+pgmatlab/) folder.

Folders use the plus (+) prefix to be treated as a 'package' (where [+pgmatlab](src/+pgmatlab/) is the root). By adding [src/](src/) only `pgmatlab` is added to the MATLAB path. All classes and functions are accessible through sub-packages, such as: `pgmatlab.utils.millisToDateNum()`.

PAMGuardMatlab has three main sub-packages:

1. [+core](src/+pgmatlab/+core/): contains classes for reading chunks from data files.

2. [+db](src/+pgmatlab/+db/): contains functions for interacting with the database (legacy)

3. [+utils](s)
