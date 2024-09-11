// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
pragma solidity ^0.8.0;

contract Twitter is Ownable {

    uint16 public MAX_TWEET_LENGTH = 280;

    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    mapping(address => Tweet[]) public tweets;
    mapping(address => mapping(uint256 => bool)) public tweetLikes; // Track if a tweet is liked by an address

    event TweetCreated(uint256 id, address author, string content, uint256 timestamp);
    event TweetLiked(address liker, address tweetAuthor, uint256 tweetId, uint256 newLikeCount);
    event TweetUnliked(address unliker, address tweetAuthor, uint256 tweetId, uint256 newLikeCount);

    // Initialize the Ownable contract with msg.sender as the initial owner
    constructor() Ownable(msg.sender) {
        // Additional initialization logic can go here if necessary
    }

    function changeTweetLength(uint16 newTweetLength) public onlyOwner {
        MAX_TWEET_LENGTH = newTweetLength;
    }

    function getTotalLikes(address _author) external view returns (uint256) {
        uint256 totalLikes;

        for (uint256 i = 0; i < tweets[_author].length; i++) {
            totalLikes += tweets[_author][i].likes;
        }
        return totalLikes;
    }

    function createTweet(string memory _tweet) public {
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet is too long");

        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        tweets[msg.sender].push(newTweet);
        emit TweetCreated(newTweet.id, newTweet.author, newTweet.content, newTweet.timestamp);
    }

    function likeTweet(address author, uint256 id) external {
        require(id < tweets[author].length, "Invalid tweet ID");
        require(!tweetLikes[author][id], "Tweet already liked by this address");

        tweets[author][id].likes++;
        tweetLikes[author][id] = true;
        emit TweetLiked(msg.sender, author, id, tweets[author][id].likes);
    }

    function unlikeTweet(address author, uint256 id) external {
        require(id < tweets[author].length, "Invalid tweet ID");
        require(tweetLikes[author][id], "Tweet not liked by this address");

        tweets[author][id].likes--;
        tweetLikes[author][id] = false;
        emit TweetUnliked(msg.sender, author, id, tweets[author][id].likes);
    }

    function getTweet(address author, uint256 _i) public view returns (Tweet memory) {
        require(_i < tweets[author].length, "Invalid tweet index");
        return tweets[author][_i];
    }

    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }
}