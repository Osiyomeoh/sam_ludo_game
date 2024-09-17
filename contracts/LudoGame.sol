// SPDX-Liscense-Identifier: MIT

contract SamLudo {


        struct Player {
                uint256 position;
                bool hasStarted;
            }

            uint256 public constant BOARD_SIZE = 57;
            uint256 public constant WINNING_POSITION = 57;

            mapping(address => Player) public players;
            address[] public playerList;
            address public playingNow;
            uint8 public result;

            event rolledTheDice (address indexed player, uint8 result )
          

                constructor(){

                }

        function addPlayer() external {
                require(!players[msg.sender].hasStarted, "Player already exists.");
                Player memory newPlayer = Player({position: 0, hasStarted: true});
                players[msg.sender] = newPlayer;
                playerList.push(msg.sender);

                if (playerList.length == 1) {
                    playingNow = msg.sender;
                }
            }

        function _getRandomNumber() internal returns (uint8) {
                uint randomSeed = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
                return uint8(randomSeed % 6) + 1;
            }
        function rollTheDice() external {
                require(msg.sender == playingNow, "Not your turn.");
                result = _getRandomNumber();
                movePlayer(result); 
                emit rolledTheDice(msg.sender, result);
            }
           

        function movePlayer(uint8 steps) internal {
                Player storage player = players[msg.sender];
                uint8 newPosition = player.position + steps;

                 
                
                player.position = newPosition;
                emit PlayerMoved(msg.sender, newPosition);
                if (newPosition == WINNING_POSITION) {
                player.position = WINNING_POSITION; // Player wins!
                resetGame();
            } else if (newPosition < WINNING_POSITION) {
                player.position = newPosition; // Move player
            } else {
                _nextTurn(); 
            }


                
                
            }
        function _nextTurn() internal {
                uint currentIndex = _getCurrentPlayerIndex();
                uint nextIndex = (currentIndex + 1) % playerList.length;
                playingNow = playerList[nextIndex];
            }

        function _getCurrentPlayerIndex() internal view returns (uint) {
                for (uint i = 0; i < playerList.length; i++) {
                    if (playerList[i] == playingNow) {
                        return i;
                    }
                }
                return 0; 
            }

        function resetGame() internal {
                for (uint i = 0; i < playerList.length; i++) {
                    players[playerList[i]].position = 0;
                    players[playerList[i]].hasStarted = false;
                }
                delete playerList;
                emit GameReset();
            }
            function getPlayerPosition(address player) external view returns (uint8) {
                return players[player].position;
            }



}