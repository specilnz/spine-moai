-------------------------------------------------------------------------------
-- Copyright (c) 2013, Esoteric Software, TangerinaGames
-- All rights reserved.
-- 
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
-- 
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
-- 
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
-- ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
------------------------------------------------------------------------------
package.path =  package.path .. ";../../?.lua"

local spine = require "spine.spine"

local width, height = 480, 320

MOAISim.openWindow("MOAI and Spine", width, height)

local viewport = MOAIViewport.new()
viewport:setSize(width, height)
viewport:setScale(width, -height)
viewport:setOffset(-1, 1)

local layer = MOAILayer2D.new()
layer:setViewport(viewport)
MOAISim.pushRenderPass(layer)

local atlas = spine.Atlas:new("data/goblins.atlas")
local loader = spine.AtlasAttachmentLoader:new(atlas, "data/goblins.png", layer)
local json = spine.SkeletonJson:new(loader)
json.scale = 0.7

local skeletonData = json:readSkeletonDataFile("../../data/goblins/goblins.json")
local walkAnimation = skeletonData:findAnimation("walk")

local skeleton = spine.Skeleton:new(skeletonData)
skeleton.prop:setLoc(240, 300)
skeleton.flipX = true
skeleton:setSkin("goblingirl")
skeleton:setToBindPose()


local animationTime = 0
MOAIThread.new():run(function()
  while true do
    animationTime = animationTime + MOAISim.getStep()
  
    walkAnimation:apply(skeleton, animationTime, true)
    skeleton:updateWorldTransform()
    
    coroutine.yield()
  end
end)
