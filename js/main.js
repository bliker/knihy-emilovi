require(['models', 'views'], function (models, views) {
    views.books.model = models.books;
    views.books.host = document.querySelector('.list-books');
    views.books.render('list_books');

    views.authors.model = models.authors;
    views.authors.host = document.querySelector('.list-authors');
    views.authors.render('list_authors');

    window.authors = models.authors;
});

// var model = new emil.Model()
// model.fetch(function(data) {
//     var view = new emil.Presenter(data)
//     view.render('list')
// });
