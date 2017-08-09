//
// This helpers grabs the url request parameters and places it in a handy object
//
// USAGE:
// URL: http://www.example.com/test.php?abc=123&def&xyz=&something%20else
// console.log(_GET);
// > Object {abc: "123", def: true, xyz: "", something else: true}
// console.log(_GET['something else']);
// > true
// console.log(_GET.abc);
// > 123
//

var _GET = (function() {
    var _get = {};
    var re = /[?&]([^=&]+)(=?)([^&]*)/g;
    while (m = re.exec(location.search))
        _get[decodeURIComponent(m[1])] = (m[2] == '=' ? decodeURIComponent(m[3]) : true);
    return _get;
})();