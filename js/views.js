define(['templates'], function(templates) {

    var View = function() {}
    View.prototype.render = function(template) {
        var self = this;
        if(!this.model) throw 'No model is bound to this view'
        this.model.getData(function(data) {
            templates[template].initialize(self.host);
            templates[template].render(data)
        });
    };

    var exp = {}
    exp.books = new View();
    exp.authors = new View();

    return exp
});