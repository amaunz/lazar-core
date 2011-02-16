#!/usr/bin/ruby1.9

require 'yaml'
require 'rubygems'
require 'rsruby'

#require 'summary2png.rb'

#def loo2summary(loo,summary_fn,figurebasename=nil)

    loo = $*[0]
    summary_fn = $*[1]
    figurebasename=nil
    if $*.size>2 
        figurebasename=$*[2]
    end

    ad_threshold = 0.8

    tp = 0
    wtp = 0
    ad_tp = 0

    tn = 0
    wtn = 0
    ad_tn = 0

    fp = 0
    wfp = 0
    ad_fp = 0

    fn = 0
    wfn = 0
    ad_fn = 0

    weighted_accuracy = 0.0;
    ad_accuracy = 0.0;
    accuracy = 0.0;
    db_act = 0.0;

    prediction_confidences = []
    
    puts loo + ' -> ' + summary_fn
    summary = File.new(summary_fn, "w+")
    
    # parse output file and pre-sort by confidences
    preds = Array.new
    YAML::load_documents(File.open(loo)) { |p|
        if !p.nil?
            preds.push(p) if !( p['prediction'].nil? || p['db_activity'].nil? || p['confidence'].nil?)
        end
    }
    preds.sort! { |x,y| ((y['confidence']).abs) <=> ((x['confidence']).abs) }
    
    pcnt=0
    psize=preds.size

    ad_conf=0.0
    preds.each { |p|

#        if !( p['prediction'].nil? || p['db_activity'].nil?)
            pcnt=pcnt+1
            fraction=pcnt.to_f/psize.to_f

            # get primary data
            id = p['id']
            db = p['db_activity']
            db_activities = []
            pred = p['prediction']
            conf = p['confidence'].abs
            smile = p['smiles']

            if fraction >= ad_threshold
                if conf>ad_conf
                    ad_conf=conf # get ad confidence limit for plot
                end
            end

            sum = 0.0
            cnt = 0
            db.each { |a|
                sum += a.to_i
                cnt += 1
                db_activities << a.to_i
            }
            if cnt 
                db_act = sum.to_f/cnt
            end
        
            if (pred == 1 && db_act >= 0.5)
                tp += 1
                wtp += conf
                ad_tp += 1 if fraction <= ad_threshold
                prediction_confidences << [id, conf, true]
            elsif (pred == 0 && db_act < 0.5)
                tn += 1
                wtn += conf
                ad_tn += 1 if fraction <= ad_threshold
                prediction_confidences << [id, conf, true]
            elsif (pred == 1 && db_act < 0.5)
                fp += 1
                wfp += conf
                ad_fp += 1 if fraction <= ad_threshold
                prediction_confidences << [id, conf, false]
            elsif (pred == 0 && db_act >= 0.5)
                fn += 1
                wfn += conf
                ad_fn += 1 if fraction <= ad_threshold
                prediction_confidences << [id, conf, false]
            end

 #       end
    } # end parsing

    if (wtp+wtn+wfp+wfn) > 0
        weighted_accuracy = (wtp+wtn) / (wtp+wtn+wfp+wfn)
    end
    if (ad_tp+ad_tn+ad_fp+ad_fn) > 0
        ad_accuracy = (ad_tp+ad_tn).to_f / (ad_tp+ad_tn+ad_fp+ad_fn)
    end
    if (tp+tn+fp+fn) > 0
        accuracy = (tp+tn).to_f / (tp+tn+fp+fn)
    end

    sum = { 

     :weighted => {
        :tp => wtp,
        :tn => wtn,
        :fp => wfp,
        :fn => wfn,
        :accuracy => weighted_accuracy },

     :within_ad => {
        :tp => ad_tp,
        :tn => ad_tn,
        :fp => ad_fp,
        :fn => ad_fn,
        :accuracy => ad_accuracy },

     :all => {
        :tp => tp,
        :tn => tn,
        :fp => fp,
        :fn => fn,
        :accuracy => accuracy }

    }

    summary.puts sum.to_yaml
    summary.flush
    summary.close
    
  #  n = 0
  # true_predictions = 0
  #  pl_confs = []
  #  pl_cas = []
  #  prediction_confidences.each { |p|
  #    n += 1
  #    true_predictions += 1 if p[2]
  #    ca = true_predictions.to_f/n
  #    pl_confs << p[1]
  #    pl_cas << ca
  #  }

    # plot confidence vs wa
    
  #  cmax = 0.0
  #  pl_confs.each { |c|
  #      cmax=c if c>cmax
  #  }
  #  r = RSRuby.instance

  #   r.png({'filename'=>figurebasename+'.png', 'width'=>420, 'height'=>480})
  #  r.plot({'x'=>pl_confs, 'y'=>pl_cas, 'type'=>'n', 'ylab'=>'Predictive accuracy', 'ylim'=>[0.5,1], 'xlab'=>'Confidence', 'xlim'=>[cmax,3e-03] })
  #  r.rect(cmax, 0.5, ad_conf, 1, {'col'=>'grey', 'border'=>'NA'})
  #  r.lines(pl_confs,pl_cas)
  #  r.points(pl_confs,pl_cas)
  #  r.text(cmax,0.55,'Applicability domain', {'pos'=>4})
  #  r.text(cmax,0.52,"(Fraction #{ad_threshold})", {'pos'=>4})
  #  r.dev_off.call

#    r.postscript({'file'=>figurebasename+'.ps', 'width'=>420, 'height'=>480})
#    r.plot({'x'=>pl_confs, 'y'=>pl_cas, 'type'=>'n', 'ylab'=>'Predictive accuracy', 'ylim'=>[0.5,1], 'xlab'=>'Confidence', 'xlim'=>[cmax,3e-03], 'cex.axis'=> 2.5, 'cex.lab' => 2.5, 'font' => 2, 'font.lab' => 2 })
#    r.rect(cmax, 0.5, ad_conf, 1, {'col'=>'grey', 'border'=>'NA'})
#    r.lines(pl_confs,pl_cas)
#    r.points(pl_confs,pl_cas, {'cex'=>2.5})
#    r.text(cmax,0.55,'Applicability domain', {'pos'=>4, 'cex'=>2.5})
#    r.text(cmax,0.52,"(Fraction #{ad_threshold})", {'pos'=>4, 'cex'=>2.5})
#    r.dev_off.call


#end

