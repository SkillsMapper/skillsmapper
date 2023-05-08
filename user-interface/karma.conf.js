module.exports = function (config) {
    config.set({
        basePath: '',
        frameworks: ['jasmine'],
        files: [
            {pattern: 'index.html', watched: false, included: false},
            'https://code.jquery.com/jquery-3.6.0.min.js',
            'https://www.gstatic.com/firebasejs/7.18.0/firebase-app.js',
            'https://www.gstatic.com/firebasejs/7.18.0/firebase-auth.js',
            'src/**/*.js',
            'tests/**/*.spec.js',
        ],
        preprocessors: {},
        reporters: ['progress'],
        port: 9876,
        colors: true,
        logLevel: config.LOG_INFO,
        autoWatch: true,
        browsers: ['Chrome'],
        singleRun: false,
        concurrency: Infinity,
    });
};