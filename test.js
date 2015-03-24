var gardener = new Gardener();
var domtree = document.getElementById("top")
var result = gardener.convert(domtree);
console.log(result);
//
// var buildSelectorTree = function() {
// };
//
// generateNode = function(dom) {
//   var node = {
//     tagname: dom.tagName || '',
//     id: dom.id || '',
//     classes: dom.className || '',
//     children: []
//   };
//
//   if ( dom.children.length > 0 ) {
//     for ( var i = 0; i < dom.children.length; i++ ) {
//       node.children.push(generateNode(dom.children[i]));
//     }
//   }
//
//   return node;
// }
//
// var allNode = generateNode(domtree);
//
// var selectors = [];
// var prev = '';
// printNode = function(node) {
//   var tmp = prev + node.tagname;
//   if ( node.classes != '' ) {
//     tmp += '.' + node.classes;
//   }
//   tmp += ' ';
//   if ( node.children.length > 0 ) {
//     for ( var i = 0; i < node.children.length; i++ ) {
//       prev = tmp;
//       printNode(node.children[i]);
//     }
//   }
//   else {
//     selectors.push(tmp);
//     prev = '';
//   }
// }
//
// var pt = printNode(allNode);
//
// console.log(selectors);
//
