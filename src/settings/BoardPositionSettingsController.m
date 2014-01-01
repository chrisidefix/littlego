// -----------------------------------------------------------------------------
// Copyright 2012-2013 Patrick Näf (herzbube@herzbube.ch)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// -----------------------------------------------------------------------------


// Project includes
#import "BoardPositionSettingsController.h"
#import "../main/ApplicationDelegate.h"
#import "../play/model/BoardPositionModel.h"
#import "../ui/TableViewCellFactory.h"
#import "../ui/UiUtilities.h"

// Constants
NSString* discardFutureMovesAlertText = @"Discard future moves alert";


// -----------------------------------------------------------------------------
/// @brief Enumerates the sections presented in the "Board position" user
/// preferences table view.
// -----------------------------------------------------------------------------
enum MoveHistoryTableViewSection
{
  MarkNextMoveSection,
  DiscardFutureMovesAlertSection,
  MaxSection
};

// -----------------------------------------------------------------------------
/// @brief Enumerates items in the MarkNextMoveSection.
// -----------------------------------------------------------------------------
enum MarkNextMoveSectionItem
{
  MarkNextMoveItem,
  MaxMarkNextMoveSectionItem
};

// -----------------------------------------------------------------------------
/// @brief Enumerates items in the DiscardFutureMovesAlertSection.
// -----------------------------------------------------------------------------
enum DiscardFutureMovesAlertSectionItem
{
  DiscardFutureMovesAlertItem,
  MaxDiscardFutureMovesAlertSectionItem
};


// -----------------------------------------------------------------------------
/// @brief Class extension with private properties for
/// BoardPositionSettingsController.
// -----------------------------------------------------------------------------
@interface BoardPositionSettingsController()
@property(nonatomic, assign) BoardPositionModel* boardPositionModel;
@end


@implementation BoardPositionSettingsController

// -----------------------------------------------------------------------------
/// @brief Convenience constructor. Creates a BoardPositionSettingsController
/// instance of grouped style.
// -----------------------------------------------------------------------------
+ (BoardPositionSettingsController*) controller
{
  BoardPositionSettingsController* controller = [[BoardPositionSettingsController alloc] initWithStyle:UITableViewStyleGrouped];
  if (controller)
  {
    [controller autorelease];
    controller.boardPositionModel = [ApplicationDelegate sharedDelegate].boardPositionModel;
  }
  return controller;
}

// -----------------------------------------------------------------------------
/// @brief Deallocates memory allocated by this BoardPositionSettingsController
/// object.
// -----------------------------------------------------------------------------
- (void) dealloc
{
  self.boardPositionModel = nil;
  [super dealloc];
}

// -----------------------------------------------------------------------------
/// @brief Called after the controller’s view is loaded into memory, usually
/// to perform additional initialization steps.
// -----------------------------------------------------------------------------
- (void) viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Board position settings";
}

// -----------------------------------------------------------------------------
/// @brief UITableViewDataSource protocol method.
// -----------------------------------------------------------------------------
- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
  return MaxSection;
}

// -----------------------------------------------------------------------------
/// @brief UITableViewDataSource protocol method.
// -----------------------------------------------------------------------------
- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
  switch (section)
  {
    case MarkNextMoveSection:
      return MaxMarkNextMoveSectionItem;
    case DiscardFutureMovesAlertSection:
      return MaxDiscardFutureMovesAlertSectionItem;
    default:
      assert(0);
      break;
  }
  return 0;
}

// -----------------------------------------------------------------------------
/// @brief UITableViewDataSource protocol method.
// -----------------------------------------------------------------------------
- (NSString*) tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section
{
  switch (section)
  {
    case DiscardFutureMovesAlertSection:
      return @"If you make or discard a move while you are looking at a board position in the middle of the game, all moves that have been made after this position will be discarded. If this option is turned off you will NOT be alerted that this is going to happen.";
    default:
      break;
  }
  return nil;
}

// -----------------------------------------------------------------------------
/// @brief UITableViewDataSource protocol method.
// -----------------------------------------------------------------------------
- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
  UITableViewCell* cell = [TableViewCellFactory cellWithType:SwitchCellType tableView:tableView];
  UISwitch* accessoryView = (UISwitch*)cell.accessoryView;
  switch (indexPath.section)
  {
    case MarkNextMoveSection:
    {
      cell = [TableViewCellFactory cellWithType:SwitchCellType tableView:tableView];
      UISwitch* accessoryView = (UISwitch*)cell.accessoryView;
      cell.textLabel.text = @"Mark next move";
      accessoryView.on = self.boardPositionModel.markNextMove;
      [accessoryView addTarget:self action:@selector(toggleMarkNextMove:) forControlEvents:UIControlEventValueChanged];
      break;
    }
    case DiscardFutureMovesAlertSection:
    {
      cell.textLabel.text = discardFutureMovesAlertText;
      cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
      cell.textLabel.numberOfLines = 0;
      accessoryView.on = self.boardPositionModel.discardFutureMovesAlert;
      [accessoryView addTarget:self action:@selector(toggleDiscardFutureMovesAlert:) forControlEvents:UIControlEventValueChanged];
      break;
    }
    default:
    {
      assert(0);
      break;
    }
  }
  return cell;
}

// -----------------------------------------------------------------------------
/// @brief UITableViewDelegate protocol method.
// -----------------------------------------------------------------------------
- (CGFloat) tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
  CGFloat height = tableView.rowHeight;
  if (DiscardFutureMovesAlertSection == indexPath.section)
  {
    NSString* cellText = discardFutureMovesAlertText;
    height = [UiUtilities tableView:tableView
                heightForCellOfType:SwitchCellType
                           withText:cellText
             hasDisclosureIndicator:false];
  }
  return height;
}

// -----------------------------------------------------------------------------
/// @brief UITableViewDelegate protocol method.
// -----------------------------------------------------------------------------
- (void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

// -----------------------------------------------------------------------------
/// @brief Reacts to a tap gesture on the "Mark next move" switch. Writes the
/// new value to the appropriate model.
// -----------------------------------------------------------------------------
- (void) toggleMarkNextMove:(id)sender
{
  UISwitch* accessoryView = (UISwitch*)sender;
  self.boardPositionModel.markNextMove = accessoryView.on;
}

// -----------------------------------------------------------------------------
/// @brief Reacts to a tap gesture on the "Discard future moves alert" switch.
/// Writes the new value to the appropriate model.
// -----------------------------------------------------------------------------
- (void) toggleDiscardFutureMovesAlert:(id)sender
{
  UISwitch* accessoryView = (UISwitch*)sender;
  self.boardPositionModel.discardFutureMovesAlert = accessoryView.on;
}

@end
