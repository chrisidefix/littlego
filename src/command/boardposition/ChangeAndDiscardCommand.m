// -----------------------------------------------------------------------------
// Copyright 2013 Patrick Näf (herzbube@herzbube.ch)
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
#import "ChangeAndDiscardCommand.h"
#import "ChangeBoardPositionCommand.h"
#import "../backup/BackupGameCommand.h"
#import "../../go/GoBoardPosition.h"
#import "../../go/GoGame.h"
#import "../../go/GoMoveModel.h"


// -----------------------------------------------------------------------------
/// @brief Class extension with private methods for ChangeAndDiscardCommand.
// -----------------------------------------------------------------------------
@interface ChangeAndDiscardCommand()
/// @name Private helpers
//@{
- (bool) shouldDiscardBoardPositions;
- (bool) discardMoves;
//@}
@end


@implementation ChangeAndDiscardCommand


// -----------------------------------------------------------------------------
/// @brief Executes this command. See the class documentation for details.
// -----------------------------------------------------------------------------
- (bool) doIt
{
  bool shouldDiscardBoardPositions = [self shouldDiscardBoardPositions];
  if (! shouldDiscardBoardPositions)
    return true;
  // Before we discard, first change to a board position that will be valid
  // even after the discard
  bool success = [[[ChangeBoardPositionCommand alloc] initWithOffset:-1] submit];
  if (! success)
    return false;
  success = [self discardMoves];
  if (! success)
    return false;
  success = [[[BackupGameCommand alloc] init] submit];
  if (! success)
    return false;
  return success;
}

// -----------------------------------------------------------------------------
/// @brief Private helper for doIt(). Returns true if board positions need to be
/// discarded, false otherwise.
// -----------------------------------------------------------------------------
- (bool) shouldDiscardBoardPositions
{
  GoGame* game = [GoGame sharedGame];
  GoBoardPosition* boardPosition = game.boardPosition;
  if (boardPosition.isFirstPosition && 1 == boardPosition.numberOfBoardPositions)
    return false;
  else
    return true;
}

// -----------------------------------------------------------------------------
/// @brief Private helper for doIt(). Returns true on success, false on failure.
// -----------------------------------------------------------------------------
- (bool) discardMoves
{
  GoGame* game = [GoGame sharedGame];
  enum GoGameState gameState = game.state;
  assert(GoGameStateGameHasEnded != gameState);
  if (GoGameStateGameHasEnded == gameState)
    return false;
  GoBoardPosition* boardPosition = game.boardPosition;
  int indexOfFirstMoveToDiscard = boardPosition.currentBoardPosition;
  GoMoveModel* moveModel = game.moveModel;
  [moveModel discardMovesFromIndex:indexOfFirstMoveToDiscard];
  return true;
}

@end
