part of '../dom.dart';

@protected
bool isHydrating = false;

void startHydrating() {
  isHydrating = true;
}

void endHydrating() {
  isHydrating = false;
}
