# ErrorForm

Windows dialog boxes are a dreary affair, but all programmers like to use them because they are so easy to use. They are built directly into the Windows API, require no configuration, and can be called up with a single line of code. However, they do not have automatic line breaks and cannot display text in **bold**, __italics__, or color. And you cannot select a font either. As I said: dreary.

I've always wanted a replacement for MessageBox() and the like, but as simple as such a project sounds, it's not really easy. So I thought I'd try using AI.

**Warning!** This subproject was implemented almost entirely with AI!

Spoiler: It didn't go particularly well.

I chose Claude Sonnet 4 as the AI because it is reasonably affordable and has been described online as particularly easy to program and capable. Visual Studio Code with GitHub Copilot was used as the editor.
First, I assigned Claude a role, specified my requirements as precisely as possible, and peppered them with examples of how I intended to use the tool. Then I asked Claude to summarize the requirements in the form of a prompt in a file called “PROMPT.md.”

From then on, this “PROMPT.md” file served as a notepad for Claude so that it wouldn't lose focus on the requirements, because artificial intelligence suffers from Alzheimer's due to its design principles.

## Vibe Coding

Since I'm already working with AI, let's hear from Google AI and explain what “vibe coding” means:

How does vibe coding work?

* Prompt-based:

The user gives detailed or even just general instructions (prompts) in natural language to an LLM, e.g., GPT.

* Code generation:

The AI converts these instructions into functional source code, reducing the need for manual programming. 

* Collaboration:

The process is similar to a collaboration in which the human developer sets the “vibes” or overall direction and the AI takes care of the details and implementation.

Until now, I had only used AI for the simplest, manual tasks, simply to save time. Vibe Coding, however, gives the AI complete control over development.

At the beginning of the session, Claude immediately had great ideas and was able to package them into a functional interface. Simple tasks, such as interpreting a limited form of Markdown, tokenizing words, and outputting them to a canvas, worked quite well.

But what was annoying right from the start was the lack of testing. The entire code is untestable in its current state because important design principles for software testing were not taken into account (the most important ones here are dependency injection (DI) and inversion of control (IoC)).

Claude also inserted “dummies” into the code: functions that did not perform any actual calculations but returned sample results. These were then implemented on demand. I also find that the code lacks proper error handling.

The code was changed with each new prompt, but without questioning the basic design. The code behaved like a soccer ball created by sticking plasters on a balloon until it no longer burst when kicked.

Claude also fantasized about types that he only described as “forward-thinking design features” when asked and which, on closer inspection, cannot be implemented at all in the current design.

## Conclusion

After three hours of “vibe coding” with Claude, I now have a module

* that cannot be tested,
* that I do not fully understand,
* that Claude himself no longer understands,
* and that violates fundamental principles of maintainable code
* BUT in 10% of the time I would have spent doing all this manually.

## Why the application was successful nonetheless

The scope and limitations of AI must be continuously evaluated during the rapid development of software tools. I see great potential for AI in the areas of

* prototyping
* unit testing
* very simple scripts
* evaluation of existing code

In this case, it was a modular, encapsulated library with a single public interface and no side effects, which is perfectly usable under the premise of “use at your own risk.”

## Dealing with AI-generated code

I recommend that all serious programmers treat AI-generated code with caution. Do not implement anything that you do not fully understand—and above all, never check this code into source code management.

Refrain from using “Agent” mode in Visual Studio Code. Make specific, precise requests and ask for suggestions. Claude will come up with good ideas, many of which will be useful. Only implement the code once you fully understand it. Only check in the code once you have a good unit test that can be executed without errors.

As a pure software developer who is closed to new topics, you will have a difficult time in the future. However, those who know the limits and possibilities of AI and are able to apply it in a productive setting will actually increase their productivity.
