import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StickySectionList extends StatelessWidget {
  final StickySectionListDelegate? delegate;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final bool? primary;
  StickySectionList({this.delegate, this.scrollController, this.scrollPhysics, 
  this.primary, Key? key}) : super(key: key);

  final StickySectionController _controller = StickySectionController();
  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    if (delegate != null) {
      for (int i = 0; i < delegate!.getSectionCount(); i++) {
        children.add(StickySection(
          controller: _controller,
          child: delegate!.buildSection(context, i),
        ));
        children.add(SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return delegate!.buildItem(context, i, index);
          }, childCount: delegate!.getItemCount(i)),
        ));
      }
    }

    return CustomScrollView(
      controller: scrollController,
      physics: scrollPhysics,
      primary: primary,
      slivers: children,
    );
  }
}

class StickySectionListDelegate {
  final int Function() getSectionCount;
  final int Function(int sectionIndex) getItemCount;
  final Widget Function(BuildContext context, int sectionIndex) buildSection;
  final Widget Function(BuildContext context, int sectionIndex, int itemIndex)
      buildItem;

  StickySectionListDelegate(
      {required this.buildItem,
      required this.buildSection,
      required this.getItemCount,
      required this.getSectionCount});
}

class StickySectionController {
  List<_StickySectionRenderBox> stickySectionList = [];
}

class StickySection extends SingleChildRenderObjectWidget {
  final Widget child;
  final StickySectionController controller;
  const StickySection({
    required this.controller,
    required this.child,
    key,
  }) : super(key: key, child: child);

  @override
  _StickySectionRenderBox createRenderObject(BuildContext context) {
    return _StickySectionRenderBox(controller: controller);
  }
}

class _StickySectionRenderBox extends RenderSliverSingleBoxAdapter {
  final StickySectionController controller;

  _StickySectionRenderBox({required this.controller, child})
      : super(child: child) {
    controller.stickySectionList.add(this);
  }

  bool pinned = false;
  double offsetY = 0;

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child?.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    double childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }

    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      visible: true,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0,
    );

    offsetY =
        constraints.viewportMainAxisExtent - constraints.remainingPaintExtent;

    var currentIndex = controller.stickySectionList.indexOf(this);
    var lastPinnedIndex = controller.stickySectionList
        .lastIndexWhere((element) => element.pinned);

    if (!pinned) {
      if (currentIndex > lastPinnedIndex && offsetY == 0) {
        setChildParentData(
            child!, constraints.copyWith(scrollOffset: 0), geometry!);
      } else {
        setChildParentData(child!, constraints, geometry!);
      }
    } else {
      if (currentIndex < lastPinnedIndex) {
        setChildParentData(
            child!, constraints.copyWith(scrollOffset: childExtent), geometry!);
      }
    }
    pinned = offsetY == 0;
    calculatePinned(this);
  }

  void calculatePinned(_StickySectionRenderBox renderBox) {
    _StickySectionRenderBox? pinnedStickySection;

    //获取最后一个固定的item
    for (int i = controller.stickySectionList.length - 1; i >= 0; i--) {
      var item = controller.stickySectionList[i];
      if (item.pinned) {
        pinnedStickySection = item;
        break;
      }
    }

    if (pinnedStickySection == null) return null;

    _StickySectionRenderBox? nextStickySection;
    var nextIndex =
        controller.stickySectionList.indexOf(pinnedStickySection) + 1;
    if (controller.stickySectionList.length > nextIndex) {
      nextStickySection = controller.stickySectionList[nextIndex];
    }

    if (nextStickySection == null) return;

    if (nextStickySection.geometry != null &&
        nextStickySection.geometry!.paintExtent > nextStickySection.offsetY) {
      var scrollOffset =
          nextStickySection.geometry!.paintExtent - nextStickySection.offsetY;
      scrollOffset = scrollOffset.floorToDouble();

      pinnedStickySection.setChildParentData(
          pinnedStickySection.child!,
          pinnedStickySection.constraints.copyWith(scrollOffset: scrollOffset),
          pinnedStickySection.geometry!);
    } else {
      pinnedStickySection.setChildParentData(
          pinnedStickySection.child!,
          pinnedStickySection.constraints.copyWith(scrollOffset: 0),
          pinnedStickySection.geometry!);
    }
  }
}
