define('models', function() {

    /**
     * Global model methods
     */
    var Model = function () {};

    Model.prototype.getData = function(callback) {
        var self = this;
        if(this.data) {
           return this.data;
        } else {
            this.fetch(function(data) {
                self.data = data;
                callback.call(window, data);
            });
        }
    };

    Model.prototype.error = function(err) {
        console.error(err);
    };

    Model.prototype.process = function (data) {
        return data;
    }

    Model.prototype.fetch = function (url, callback) {
        var self = this;
        console.log(url);
        $.getJSON(url)
            .success(function (data) {
                // console.log(callback);
                callback.call(window, self.process(data));
            }).error(self.error);
    }

    var exp = {};
    exp.books = new Model();
    exp.authors = new Model();

    exp.books.fetch = function (callback) {
        Object.getPrototypeOf(this).fetch('https://rawgithub.com/bliker/knihy-emilovi/master/books.json', callback);
    }

    exp.authors.fetch = function (callback) {
        Object.getPrototypeOf(this).fetch('https://rawgithub.com/bliker/knihy-emilovi/master/authors.json', callback);
    }

    return exp;
});