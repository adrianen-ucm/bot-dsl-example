# Bot DSL example

This is an example of using a Typed Tagless Final Interpreter for defining a [DSL of commands](./src/Session/Class.purs) that can be interpreted by a [runtime](./src/Session/Runtime.purs), which is currently an [FFI mock](./src/Effect/Aff/Runtime.js). This DSL consists of commands that can be run as a user in a simple blog website, and a [parser](./src/Session/Parser.purs) is also offered to read sessions from text like [this](./examples/session-demo-simple.txt) which, when interpreted by the provided implementation, outputs the following:

```sh
Login with user "adri"
|  Sleep 2000.0 ms
|  Random post (id 1)
|  |  reaction angry
|  |  reaction smile
|  |  Comment with "Hi"
|  |  |  reaction sad
|  |  |  Edit with "Hi?"
|  |  |  Sleep 500.0 ms
|  |  |  Reply with "Hi"
|  |  |  |  reaction sad
|  |  |  Remove
|  |  Comment with "Bye"

🤖 Every step seems ok from my side. Well done.
```

## End usage example

Download the file [`dist.tar.gz`](./dist.tar.gz) from this repository. Once it has been uncompressed, the file [`session-demo-detailed.txt`](./examples/session-demo-detailed.txt) can be followed as a guide.

## Usage from the project sources

### Node

```bash
# Install dependencies
npm i

# Compile the PureScript sources
npm run build

# Run a session from the specified file
npm run session [session file path]

# Generate the distribution file in ./dist.tar.gz
npm run bundle
```

### PureScript EDSL

Sessions can be defined in [PureScript](https://www.purescript.org/) as in the following example:

```haskell
import Session.Class

mySession = login { username: "user", password: "pass"} (
    randomPost (
        reactToPost Smile :>: 
        reactToPost Angry :>: 
        createComment "Example" (
            reactToPost Laugh :>: 
            editComment "Example edited" :>:
            replyToComment "Reply example" nothing :>:
            removeComment
        )
    )
)
```

Which can be interpreted as follows:

```haskell
import Effect.Aff (launchAff_)
import Session.Runtime (eval)

myConfig = 
    { apiBaseUrl: "https://api.com"
    }

launchAff_ (eval myConfig mySession)
```