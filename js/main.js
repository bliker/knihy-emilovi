var emil = {}

emil.Model = function() {}
emil.Model.prototype.group = function(data) {
    var authors = {};
    for (var i = 0; i < data.length; i++) {
        var c = data[i]
        if(authors.hasOwnProperty(c.author)) {
            authors[c.author].push(c);
        } else {
            authors[c.author] = [c];
        }
    };
    return authors;
}
emil.Model.prototype.fetch = function(callback) {
    var that = this;
    $.getJSON('https://rawgithub.com/bliker/knihy-emilovi/master/output.json')
        .success(function (data) {
            callback.call(window, that.group(data));
        })
        .error(function (error) {
            console.error(error);
            alert('Nastala chyba pri stahovani knih, refresh?')
        });
};


emil.Presenter = function(data) {
    this.data = data;
    this.host = document.querySelector('main.content');
}

/**
 * Parse author data, return template string
 */
emil.Presenter.prototype.templates = {

    list: function (items) {
        var t = this.get_template('#template-list');
        t.querySelector('.list-author').innerText = items[0].author

        var buffer = ''
        for (var i = 0; i < items.length; i++) {
            buffer += ('<span>' + items[i].title + '</span>')
        };
        t.querySelector('.list-titles').innerHTML = buffer;
        return t.cloneNode(true)
    },

    grid: function (item) {
        this.get_template('')
    },

    // Private

    get_template: function (name) {
        return document.querySelector(name).content
    }
}

emil.Presenter.prototype.render = function(template) {

    for (var author in this.data) {
        var c = this.data[author];
        console.log(this.templates['list'](c));
    }
};

var model = new emil.Model()
model.fetch(function(data) {
    var view = new emil.Presenter(data)
    view.render('list')
});
