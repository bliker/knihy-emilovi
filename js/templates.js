define(function () {

    function getTemplate(selector) {
        return document.querySelector(selector).content;
    }

    function getTemplateClone(selector) {
        return document.querySelector(selector).content.cloneNode(true);
    }

    var Template = function(template) {
        this.template = template;
    }

    Template.prototype.initialize = function(host) {
        this.host = host;
    };

    Template.prototype.beforeRender = function() {
        this.host.innerHtml = '';
    };
    Template.prototype.afterRender = function() {};

    Template.prototype.render = function(data) {

        this.beforeRender();

        for (var i = data.length - 1; i >= 0; i--) {
            var t = this.template.cloneNode(true);
            this.host.appendChild(this.renderOne(data[i], t));
        };

        this.afterRender();
    };

    exp = {};

    /**
     * Rendering list of books
     */

    exp.list_books = new Template(getTemplate('#template-list-books'));
    exp.list_books.renderOne = function(data, template) {
        t = template.querySelector('div');
        t.innerText = data.title;
        t.setAttribute('data-id', data.id)
        t.setAttribute('data-authorid', data.author_id)

        return template;
    };

    /**
     * Rendering the authors
     */

    exp.list_authors = new Template(getTemplate('#template-list-authors'));
    exp.list_authors.renderOne = function (data, template) {
        t = template.querySelector('div');
        t.setAttribute('data-id', data.id)
        t.innerText = data.name;
        return template;
    }
    return exp;
});

