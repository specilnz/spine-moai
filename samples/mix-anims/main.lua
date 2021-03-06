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


local loader = spine.AttachmentLoader:new()
function loader:createImage(attachment)

  local deck = MOAIGfxQuad2D.new()
  deck:setTexture("../../data/spineboy/" .. attachment.name .. ".png")
  deck:setUVRect(0, 0, 1, 1)
  deck:setRect(0, 0, attachment.width, attachment.height)
  
  local prop = MOAIProp.new()
  prop:setDeck(deck)  
  prop:setPiv(attachment.width / 2, attachment.height / 2)
  layer:insertProp(prop)

  return prop
end


local json = spine.SkeletonJson:new(loader)
json.scale = 0.7

local skeletonData = json:readSkeletonDataFile("../../data/spineboy/spineboy.json")

local skeleton = spine.Skeleton:new(skeletonData)
skeleton.prop:setLoc(240, 300)
skeleton.flipX = true
skeleton.flipY = false
skeleton.debugBones = true
skeleton.debugLayer = layer
skeleton:setToBindPose()

local animationStateData = spine.AnimationStateData:new(skeletonData)
animationStateData:setMix("walk", "jump", 0.2)
animationStateData:setMix("jump", "walk", 0.2)
 
local animationState = spine.AnimationState:new(animationStateData)
animationState:setAnimation("walk", true)
 

MOAIThread.new():run(function()
  while true do
    animationState:update(MOAISim.getStep())
    animationState:apply(skeleton)
    
    skeleton:updateWorldTransform()
    
    if animationState.current.name == "jump" and animationState.currentTime > animationState.current.duration then
      animationState:setAnimation("walk", true)
    end
    
    coroutine.yield()
  end
end)

MOAIInputMgr.device.mouseLeft:setCallback(function(down)
  if down and animationState.current.name ~= "jump" then
    animationState:setAnimation("jump")
  end
end)
