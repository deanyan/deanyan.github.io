---
layout: post
title:  "Make your SASS or LESS code customizable!"
date:   2015-05-10 10:29:44
categories: javascript sass update
---
I've recently been working on an inside tasks, which we write our own skin theme using SASS, with modular way no doubt. We devide files into variables, utils, buttons, header, tips etc. Then a natural idea come to my mind, that's if we want to change the color theme to differents, radius of button more sharp, what should we do? The answers is to change each SASS variables line by line. Sure, it's one way to make it, but it's time consuming and little appreciate. We're technician, aren't we?
There should be a routine script instead of us to do that. This is the way [Bootstrap customize][bootstrap-customize] enlightens.

You see the most heavy hard work is of dozens of input fields where you put into desired value, for other check boxs, they're as simple as if your include them in your code or not. Then how will make your input custom value be back, and work in your 'download' code. There could be a read-write process for your variables.scss files, then it involes server side code, nodejs, ruby, php etc. Well, if you look into the code of docs Bootstrap on github [github-bootstrap-docs], you disclose
the myth. Let's crack into code, see what the code do.

All the heavy-lifting is made by file customizer.js, the call stack is generateCSS, generateLESS, generateCustomLess and in the end compileLESS. The interesting thing is there's not any logic relating with file reading/writing, it's all client-side JavaScript code. How can it be?Well, if you look into function of generateLESS, 

{% highlight javascript %}
function generateLESS(lessFilename, lessFileIncludes, vars) {
    var lessSource = __less[lessFilename]

        var lessFilenames = includedLessFilenames(lessFilename)
        $.each(lessFilenames, function (index, filename) {
                var fileInclude = lessFileIncludes[filename]
                ...

                // Custom variables are added after Bootstrap variables so the custom
                // ones take precedence.
                if (('variables.less' === filename) && vars) lessSource += generateCustomLess(vars)
                })

    lessSource = lessSource.replace(/@import[^\n]*/gi, '') // strip any imports
        return lessSource
}
{% endhighlight %}

That's a comment to the fact reads 'Custom variables are added...'. Aha, the wit thing is your customized code Bootstrap generate is <b>CSS</b> instead of LESS, they use client side LESS.js to compile the source .less code to .css, then you take advantage of compile time to override predefined variables declared in variables.less file.

Conquer the summit of mountain, you flaten out your mind to see other functions, generateCSS read all variables inputs value in customize page,

{% highlight javascript %}
function generateCSS(preamble) {
    var promise = $.Deferred()
        var oneChecked = false
        var lessFileIncludes = {}
    $('#less-section input').each(function () {
            var $this = $(this)
            var checked = $this.is(':checked')
            lessFileIncludes[$this.val()] = checked

            oneChecked = oneChecked || checked
            })

    if (!oneChecked) return false

        var result = {}
    var vars = {}

    $('#less-variables-section input')
        .each(function () {
                $(this).val() && (vars[$(this).prev().text()] = $(this).val())
                })

    var bsLessSource    = preamble + generateLESS('bootstrap.less', lessFileIncludes, vars)
}
{% endhighlight %}

you'll also see a variable called lessFileIncludes, which is a map of check to decide if one of .less file will be compile into custom <b>CSS</b>. The variable bsLessSource is the defacto outcome to be polished further by compileLESS function,

{% highlight javascript %}

function compileLESS(lessSource, baseFilename, intoResult) {
    var promise = $.Deferred()
        var parser = new less.Parser({
            paths: ['variables.less', 'mixins.less'],
            optimization: 0,
            filename: baseFilename + '.css'
        })

    parser.parse(lessSource, function (parseErr, tree) {
        if (parseErr) {
            return promise.reject(parseErr)
        }
        try {
            intoResult[baseFilename + '.css']     = cw + tree.toCSS()
            intoResult[baseFilename + '.min.css'] = cw + tree.toCSS({ compress: true })
        }
        catch (compileErr) {
            return promise.reject(compileErr)
        }
        promise.resolve()
   })

    return promise.promise()
}
{% endhighlight %}

At last, the compiled CSS code will be zipped(by a JavaScript implementation) for you save(a JavaScript implementation as well).

[bootstrap-customize]: http://getbootstrap.com/customize 
[github-bootstrap-docs]: https://github.com/twbs/bootstrap/tree/master/docs
