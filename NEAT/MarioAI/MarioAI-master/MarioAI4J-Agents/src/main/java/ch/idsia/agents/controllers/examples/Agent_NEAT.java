package ch.idsia.agents.controllers.examples;

import java.util.Arrays;
import java.util.Collections;

import org.apache.commons.lang3.ArrayUtils;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.api.ops.impl.accum.MatchCondition;
import org.nd4j.linalg.api.ops.impl.transforms.Tanh;
import org.nd4j.linalg.factory.Nd4j;
import org.nd4j.linalg.indexing.NDArrayIndex;
import org.nd4j.linalg.indexing.conditions.Conditions;

import com.mathworks.engine.EngineException;
import com.mathworks.engine.MatlabEngine;
import com.mathworks.matlab.types.Struct;

import ch.idsia.agents.AgentOptions;
import ch.idsia.agents.IAgent;
import ch.idsia.agents.controllers.MarioHijackAIBase;
import ch.idsia.benchmark.mario.MarioSimulator;
import ch.idsia.benchmark.mario.engine.input.MarioInput;
import ch.idsia.benchmark.mario.environments.MarioEnvironment;
import ch.idsia.benchmark.mario.options.FastOpts;
import ch.idsia.benchmark.mario.options.MarioOptions;

/**
 * Usage:
 * Add  matlabroot/bin/<arch> as environment variable
 * Run "matlab.engine.shareEngine" in matlab console to share session
 * Run Agent_NEAT
 * <p>
 * Further Details see mathworks.com/help/matlab/matlab_external/setup-environment.html
 **/

public class Agent_NEAT extends MarioHijackAIBase implements IAgent {

	static MatlabEngine eng;
	Struct params;

	INDArray weightMatrix;
	INDArray activation;
	INDArray inputTiles;

	@Override
	public void reset(AgentOptions options) {
		super.reset(options);
	}

	@Override
	public MarioInput actionSelectionAI() {


		//todo only train every x frames.
		//control.jump();
		//control.runRight();


			/*Double enteties = new Double(e.entities.size());
			for (int i = 0; i < e.entities.size(); i++) {
				if(e.entities.get(i).type.equals(EntityType.DANGER))
			}*/

		int index = 0;
		double[] tiles = new double[(t.tileField.length * t.tileField[0].length) + 1];
		for (int i = 0; i < t.tileField.length; i++) {
			for (int j = 0; j < t.tileField[i].length; j++) {
				tiles[index++] = (double) t.tileField[i][j].getCode();
			}
		}

		int maxTileId = 14;
		tiles[index] = 14; //add bias
		INDArray inputTiles = Nd4j.create(tiles).div(maxTileId);
		//inputTiles.put(NDArrayIndex.point(inputTiles.length()), Nd4j.create(new Double[1]{1}));
		activation = Nd4j.concat(1, inputTiles, activation.get(NDArrayIndex.interval(inputTiles.length(), activation.length())));
		INDArray netOut = Nd4j.getExecutioner().execAndReturn(new Tanh((activation.mmul(weightMatrix))));

		activation = netOut;
		netOut = netOut.get(NDArrayIndex.interval(inputTiles.length(), inputTiles.length() + ((Double) params.get("num_output")).intValue()));

		Double maxValue = Double.NEGATIVE_INFINITY;
		int keyId = 0;
		for (int i = 0; i < netOut.length(); i++) {
			if (netOut.getDouble(i) > maxValue) {
				maxValue = netOut.getDouble(i);
				keyId = i;
			}
		}

		if (keyId == 1) {
			control.jump();
		} else if (keyId == 2) {
			control.jump();
			control.runRight();;
		} else if (keyId == 3) {
			control.sprint();
			control.runRight();
		}


		return action;
	}


	public static void main(String[] args) throws Exception {
		eng = MatlabEngine.connectMatlab(MatlabEngine.findMatlab()[0]);
		eng.eval("neat_network()");

		closeMatlabEngineOnManualExit();

		IAgent agent = new Agent_NEAT();
		agent.receiveReward(MarioEnvironment.getInstance().getIntermediateReward());

		String options = FastOpts.LEVEL_04_BLOCKS + FastOpts.AI_RECEPTIVE_FIELD(10, 10);
		String visualizeON = FastOpts.VIS_ON_2X;
		String visualizeOFF = FastOpts.VIS_OFF;
		MarioSimulator simulator = new MarioSimulator(visualizeOFF + options);

		INDArray nodesCurrent;
		INDArray connectionsCurrent;
		int maxNodeId = 0;

		eng.putVariable("isTraining", true);
		
		
		for (int iteration = 0; iteration < 100; iteration++) {

			System.out.println("iteration = " + iteration);

			((Agent_NEAT) agent).params = eng.getVariable("params");
			Object[] nodes = (Object[]) ((Agent_NEAT) agent).params.get("nodes");
			Object[] connections = (Object[]) ((Agent_NEAT) agent).params.get("connections");
			int num_networks = connections.length;
			int[] fitness = new int[connections.length];
			


			for (int currentNetworkId = 0; currentNetworkId < num_networks; currentNetworkId++) {

				nodesCurrent = Nd4j.create((double[][]) nodes[currentNetworkId]);
				connectionsCurrent = Nd4j.create((double[][]) connections[currentNetworkId]);

				maxNodeId = nodesCurrent.getColumn(0).maxNumber().intValue();

				//remove disabled connections
				INDArray enabledSelector = connectionsCurrent.getColumn(3).eq(1d);
				int[] enabledIndex = new int[Nd4j.getExecutioner().exec(new MatchCondition(enabledSelector, Conditions.equals(1)), Integer.MAX_VALUE).getInt(0)];
				int indexCounter = 0;
				for (int i = 0; i < enabledSelector.length(); i++) {
					if (enabledSelector.getInt(i) == 1) {
						enabledIndex[indexCounter++] = i;
					}
				}
				connectionsCurrent = connectionsCurrent.getRows(enabledIndex).getColumns(0, 1, 2);

				((Agent_NEAT) agent).activation = Nd4j.zeros(1, maxNodeId);
				((Agent_NEAT) agent).weightMatrix = Nd4j.zeros(maxNodeId, maxNodeId);
				for (int i = 0; i < connectionsCurrent.getColumn(0).size(0); i++) {
					((Agent_NEAT) agent).weightMatrix.put(connectionsCurrent.getColumn(0).getInt(i) - 1, connectionsCurrent.getColumn(1).getInt(i) - 1, connectionsCurrent.getColumn(2).getDouble(i));
				}

				simulator.run(agent);

				//deciding which fitness to use
				//fitness[currentNetworkId] = MarioEnvironment.getInstance().getIntermediateReward()+ 10 * MarioEnvironment.getInstance().getMario().sprite.mapX;
				//fitness[currentNetworkId] = MarioEnvironment.getInstance().getMario().sprite.mapX;
				fitness[currentNetworkId] = (int) MarioEnvironment.getInstance().getMario().sprite.x;

				
				System.out.println("Fitness Pixel: "+fitness[currentNetworkId]+"\t max: "+ MarioEnvironment.getInstance().getLevelLength()*16 + "\t|\t Fitness Bloecke: " + MarioEnvironment.getInstance().getMario().sprite.mapX+"\t max: "+MarioEnvironment.getInstance().getLevelLength()+"\t| time left: "+MarioEnvironment.getInstance().getTimeLeft()+"\t\t| win?: "+ ((int) MarioEnvironment.getInstance().getMario().sprite.mapX ==(int) MarioEnvironment.getInstance().getLevelLength()?"True":"False"));

			}
			
			int avgFitness =0;
			for(int element:fitness){
				avgFitness += element;
			}
			avgFitness = avgFitness / fitness.length;
			System.out.println("Durschnitts Fitness der Iteration: " + avgFitness);
			
			int max=0;
			max = Collections.max(Arrays.asList(ArrayUtils.toObject(fitness)));
			
			System.out.println("Fitness Elite: "+ max);
			System.out.println("-----------------------------------------------------------------------------------------------------------------------");

			eng.putVariable("marioFitness", fitness);
			eng.eval("neat_network()");

			if (iteration == 0 || iteration % 30 == 0) {
				simulator = new MarioSimulator(visualizeON + options + " " + MarioOptions.IntOption.SIMULATION_TIME_LIMIT.getParam() + " 100");
				((Agent_NEAT) agent).activation = Nd4j.zeros(1, maxNodeId);
				simulator.run(agent);
				simulator = new MarioSimulator(visualizeOFF + options);
			}

		}
		System.exit(0);

	}

	private static void closeMatlabEngineOnManualExit() {
		Runtime.getRuntime().addShutdownHook(new Thread() {
			public void run() {
				try {
					eng.close();
				} catch (EngineException e1) {
					e1.printStackTrace();
				}
			}
		});
	}
}
