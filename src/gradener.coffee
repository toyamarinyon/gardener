GardenerNestRule =
  noNest: 0
  children: 1
  child: 2

GardenerFileType =
  css: 0
  scss: 1
  less: 2
  sass: 3

class Gardener

  constructor: (args) ->
    @nestRule = GardenerNestRule.noNest
    if args? and args.nestRule?
      @nestRule = args.nestRule
    @fileType = GardenerFileType.css
    if args? and args.nestRule?
      @fileType = args.fileType
    @prevConvertString = ''
    @convertedTree = []

  convert: (domTree) ->
    @prevConvertString = ''
    @convertedTree = []
    execConvert.call(@,domTree)
    return @convertedTree

  execConvert = (dom) ->
    selectorString = ''
    selectorString += @prevConvertString if @nestRule is GardenerNestRule.noNest
    selectorString += " #"+dom.id if dom.id
    selectorString += " ."+dom.className if dom.className

    if dom.children.length > 0
      for child in dom.children
        @prevConvertString = selectorString
        execConvert.call(@,child)
    else
      @convertedTree.push selectorString
      @prevConvertString = ''
