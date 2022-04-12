require 'ruboto/activity'
require 'ruboto/toast'
require 'ruboto/widget'


=begin
require "open-uri"
require 'base64'
require 'digest/md5'
=end

import android.widget.ArrayAdapter
import android.media.AudioManager   #引用声音管理库
import android.app.AlertDialog
import android.view.LayoutInflater
import android.view.View
FEATURE_NO_TITLE = 1



if File.exist?("ChannelList.rb")
    load "ChannelList.rb"
else
    $channelList=["添加节目源"]
    $channelList[$channelList.size]="CCTV-6,http://219.151.31.38/liveplay-kk.rtxapp.com/live/program/live/cctv6hd/4000000/mnf.m3u8"
    $channelList[$channelList.size]="凤凰卫视中文台,https://playtv-live.ifeng.com/live/06OLEGEGM4G_tv1.m3u8"
    $nowChannel="https://playtv-live.ifeng.com/live/06OLEGEGM4G_tv1.m3u8"     #默认开机凤凰频道
end




class StartupActivity
    #建立界面
  def onCreate(savedInstanceState)
    super
    requestWindowFeature(FEATURE_NO_TITLE)  #隐藏标题栏
    setContentView(R.layout.startup_activity)
    @videoView=findViewById(R.id.videoView)
    @listView=findViewById(R.id.listView)
    @listView.setAlpha(0.7)     #透明度


    @audioManager=getSystemService(Context::AUDIO_SERVICE)  #声音服务

    @videoView.setVideoPath($nowChannel)
    @videoView.start

    #新建ArrayAdapter数据
    adapter=ArrayAdapter.new(self,android.R.layout.simple_list_item_1,$channelList)
    @listView.adapter=adapter



    @listView.on_item_click_listener = proc {|pa,v,p,i|
                                              if i==0
                                                listViewEdit(pa,v,p,i)
                                              else
                                                turnChannel(i)
                                              end
                                              }
    @listView.on_item_long_click_listener = lambda {|pa,v,p,i|
                                             toast "长按可编辑"
                                             listViewEdit(pa,v,p,i)
                                             return true}


=begin
    @listView.on_touch_listener  =  proc{
                                            @listView.setVisibility(-1)
                                             toast "隐藏节目列表"
                                         }
=end

    @videoView.on_click_listener =  proc{
                                    @listView.setVisibility(0)
                                    toast "显示节目列表"
                                    }




  end

  #列表编辑
  def listViewEdit(pa,v,p,i)
        builder=AlertDialog::Builder.new(self)
        dialog=builder.create
        dialogView=View.inflate(self,R.layout.activity_custom,nil)
        dialog.setView(dialogView)
        dialog.show
        @textView_Edit=dialogView.findViewById(R.id.editText_Edit)
        @button_Sure=dialogView.findViewById(R.id.button_Sure)
        @button_Cancel=dialogView.findViewById(R.id.button_Cancel)

        @textView_Edit.text=v.text if i!=0
        @button_Sure.on_click_listener= proc{
                                       if i==0
                                            $channelList[$channelList.size]=@textView_Edit.text.to_s if @textView_Edit.text.to_s!=""
                                       else
                                            $channelList[i]=@textView_Edit.text.to_s
                                            $channelList.delete("")     #删除空项
                                       end
                                      # @listView.deferNotifyDataSetChanged

                                       dialog.dismiss
                                       }
       @button_Cancel.on_click_listener= proc{
                                              dialog.dismiss
                                              }
  end



  #改变频道
  def turnChannel(channelNumber)
          $nowChannel=$channelList[channelNumber].to_s.split(",").last.to_s
          @videoView.setVideoPath($nowChannel)
          @videoView.start
          @listView.setVisibility(-1)
          #保留节目列表和当前节目源，下次重开机好恢复
          File.open("ChannelList.rb",'w') do |f|
                 f.write("$channelList=#{$channelList}\n")
                 f.write("$nowChannel=\"#{$nowChannel}\"\n")
            end
  end


end



