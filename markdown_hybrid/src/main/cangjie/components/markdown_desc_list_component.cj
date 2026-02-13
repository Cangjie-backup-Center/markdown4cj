/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
package markdown.components

import ohos.base.*
import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.hilog.Hilog
/**
 * 定义列表
 */
@Component
public class MarkdownDescListComponent {
    /**
     * markdown配置
     */
    var markdownConfiguration: MarkdownConfiguration

    /**
     * 列表节点
     */
    var nodeView: NodeView

    /**
     * 控件宽度 - 单位px
     */
    @Prop
    var componentWidth: Float64

    /**
     * 缓存的数据
     */
    var markdownCacheConfiguration: MarkdownCacheConfiguration

    /**
     * TOC列表点击事件回调
     */
    var tocListOnClick: (Int64) -> Unit

    /**
     * 脚注点击事件
     */
    var fontCallback: (String) -> Unit

    /**
     * 图片点击事件
     */
    var imageCallback: (String) -> Unit

    /**
     * 懒加载数据源
     */
    var nodeViewDataSource: NodeViewDataSource = NodeViewDataSource(ArrayList<NodeView>())

    /**
     * 自定义行内段落布局
     */
    @BuilderParam
    var customParagraphLineBuilder: (NodeView, Int64) -> Unit

    var isDescTerm: Bool = true

    var isDescDef: Bool = false

    protected override func aboutToAppear(): Unit {
        // 初始化刷新数据
        refreshData(nodeView)
        // 缓存当前控件
        markdownCacheConfiguration.descListComponent.add(this.nodeView.nodeHash, this)
    }

    protected override func aboutToDisappear(): Unit {
        // 清除当前控件
        let value = markdownCacheConfiguration.descListComponent.get(this.nodeView.nodeHash)
        if (let Some(v) <- value) {
            if (refEq(v, this)) {
                markdownCacheConfiguration.descListComponent.remove(this.nodeView.nodeHash)
            }
        } else {
            markdownCacheConfiguration.descListComponent.remove(this.nodeView.nodeHash)
        }
    }

    func build() {
        List() {
            LazyForEach(
                nodeViewDataSource,
                itemGeneratorFunc: {
                    item: NodeView, idx: Int64 => if ((item.node is DescTerm) && loagDescTerm()) {
                        // 术语
                        ListItem() {
                            MarkdownDescTermComponent(
                                markdownConfiguration: markdownConfiguration,
                                nodeView: item,
                                fontCallback: fontCallback,
                                tocListOnClick: tocListOnClick,
                                imageCallback: imageCallback,
                                componentWidth: componentWidth,
                                markdownCacheConfiguration: markdownCacheConfiguration,
                                customParagraphLineBuilder: customParagraphLineBuilder
                            )
                        }
                    } else if ((item.node is DescDef) && loagDescDef()) {
                        // 定义
                        ListItem() {
                            MarkdownDescDefComponent(
                                markdownConfiguration: markdownConfiguration,
                                nodeView: item,
                                fontCallback: fontCallback,
                                tocListOnClick: tocListOnClick,
                                imageCallback: imageCallback,
                                componentWidth: componentWidth,
                                markdownCacheConfiguration: markdownCacheConfiguration,
                                customParagraphLineBuilder: customParagraphLineBuilder
                            )
                        }
                    } else {
                        // TODO 其他节点
                        ListItem() {
                            Text("")
                        }
                    }
                },
                keyGeneratorFunc: {
                    descListNodeView: NodeView, idx: Int64 => return "${idx}-${descListNodeView.nodeHash}-${descListNodeView.contentHash}"
                }
            )
        }
        // 设置List组件排列方向
        .listDirection(Axis.Vertical)
        // List交叉轴方向宽度大于ListItem交叉轴宽度 * lanes时，ListItem在List交叉轴方向的布局方式，默认为首部对齐
        .alignListItem(ListItemAlign.Start)
        // 设置组件自身的宽度
        .width(100.percent)
    }

    func loagDescTerm(): Bool {
        isDescTerm = true
        isDescDef = false
        return true
    }

    func loagDescDef(): Bool {
        isDescDef = true
        return true
    }

    /**
     * 数据刷新
     */
    public func refreshData(nodeView: NodeView): Unit {
        Hilog.error(123, "cccc", " ===================> 定义列表isEndData：${nodeView.isEndData}, isDescTerm: ${isDescTerm}, isDescDef: ${isDescDef}")
        this.nodeView = nodeView
        let refreshNodeViews = nodeView.children
        let refreshNodeViewSize: Int64 = refreshNodeViews.size // 刷新进来的数据长度
        let dataSourceSize: Int64 = nodeViewDataSource.totalCount() // 页面缓存的数据长度
        Hilog.error(123, "cccc", " ===================> 定义列表dataSourceSize：${dataSourceSize}")
        if (refreshNodeViewSize == 0) {
            return
        }
//        if (isDescTerm && dataSourceSize > 0) { // 上一条是术语，当前一条是定义，需要刷新上一条术语的数据，去掉打字机效果
//            Hilog.error(123, "cccc", " ===================> 去掉打字机效果")
//            var lastNode = nodeViewDataSource.getData(dataSourceSize -1)
//            nodeView.typewriterState = -1
//            isDescTerm = false
//            refreshNodeViewDataSource(nodeView, lastNode.children, dataSourceSize, dataSourceSize, nodeViewDataSource, "desclist", markdownCacheConfiguration, Option<HashMap<Int64, MarkdownTableBlockRowComponent>>.None)
//        }
//        let newNodeType = nodeView.
        refreshNodeViewDataSource(nodeView, refreshNodeViews, refreshNodeViewSize, dataSourceSize, nodeViewDataSource, "desclist", markdownCacheConfiguration, Option<HashMap<Int64, MarkdownTableBlockRowComponent>>.None)
    }
}
