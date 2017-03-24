# Barnplay

## Dependencys
Our project currently uses two third-party libraries and to ensure
that everyone has the same versions and simplify the build process

## Carthage
Carthage is a dependecy manager that fixes that issue for us

### Install Carthage
If you have homebrew installed (i recommend it, http://www.brew.sh ):

    $ brew update
    $ brew install carthage

Otherwise, head over to the carthage gitub page and download the installer
https://github.com/Carthage/Carthage

## Running for the first time
When you first clone the repo , your build will problably fail if you're using
any of the third-part libraries and you will need to tell Carthage to install them

So open up your terminal and navigate to the root folder of the project, then run:

    $ carthage bootstrap --platform tvOS

This will take a while and then it will build all dependecys

## My build fails because a dependecy is missing!
Don't worry, somebody probably just added a dependecy, just run:

    $ carthage update

## SwiftLint
Checks the syntax for things that aren't swifty enough.
Install with homebrew

    $ brew install swiftlint
