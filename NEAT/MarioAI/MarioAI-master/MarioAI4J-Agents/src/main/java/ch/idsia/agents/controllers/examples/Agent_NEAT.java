package ch.idsia.agents.controllers.examples;

import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

import org.apache.commons.lang3.ArrayUtils;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.api.ops.impl.accum.MatchCondition;
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
import org.nd4j.linalg.ops.transforms.Transforms;

/**
 * Usage:
 * Add  matlabroot/bin/<arch> as environment variable
 * Run "matlab.engine.shareEngine" in matlab console to share session
 * Run Agent_NEAT
 * <p>
 * Further Details see mathworks.com/help/matlab/matlab_external/setup-environment.html
 **/

public class Agent_NEAT extends MarioHijackAIBase implements IAgent {

	private static MatlabEngine eng;
	private Struct params;
	
	private INDArray weightMatrix;
	private INDArray activation;
	private static int experimentID;
	private static int lastPositon = 0;
	private static int lastPositionCheckTimer = 0;

	private static final String EXPERIMENT_TYPE_LEARNINGRATE = "learningRates";

	@Override
	public void reset(AgentOptions options) {
		super.reset(options);
	}

	@Override
	public MarioInput actionSelectionAI() {

		//todo only train every x frames.
		/*Double enteties = new Double(e.entities.size());
		for (int i = 0; i < e.entities.size(); i++) {
			if(e.entities.get(i).type.equals(EntityType.DANGER))
		}*/

		int index = 0;
		double[] tiles = new double[(t.tileField.length * (t.tileField[0].length - mario.egoCol)) + 1];
		for (int i = 0; i < t.tileField.length; i++) {
			for (int j = mario.egoCol; j < t.tileField[0].length; j++) {
				tiles[index++] = t.tileField[i][j].getCode();
			}
		}

		//int maxTileId = 14;
		tiles[index] = 1; //add bias
		INDArray inputTiles = Nd4j.create(tiles);//.div(maxTileId);
		activation = Nd4j.concat(1, inputTiles, activation.get(NDArrayIndex.interval(inputTiles.length(), activation.length())));
		INDArray netOut = Transforms.tanh(activation.mmul(weightMatrix));

		activation = netOut;
		netOut = netOut.get(NDArrayIndex.interval(inputTiles.length(), inputTiles.length() + ((Double) params.get("num_output")).intValue()));

		//stop simulation when mario stuck
		if(lastPositionCheckTimer == 0) {
			if(lastPositon != 0 && lastPositon == (int) MarioEnvironment.getInstance().getMario().sprite.x){
				MarioEnvironment.getInstance().levelScene.mario.die("Stuck");
			}
			lastPositon = (int) MarioEnvironment.getInstance().getMario().sprite.x;
			lastPositionCheckTimer = 10;
		} else {
			lastPositionCheckTimer--;
		}

		/*Double maxValue = Double.NEGATIVE_INFINITY;
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
		}*/

		if (netOut.getDouble(1) > 0.2) {
			control.jump();
		}
		if (netOut.getDouble(2) > 0.2) {
			control.runRight();
		}
		if (netOut.getDouble(3) > 0.2) {
			control.sprint();
		}


		return action;
	}


	public static void main(String[] args) throws Exception {
		eng = MatlabEngine.connectMatlab(MatlabEngine.findMatlab()[0]);
		closeMatlabEngineOnManualExit();

		boolean displayGameWindow = false;
		int num_iterations = 500;

		String experimentType = EXPERIMENT_TYPE_LEARNINGRATE;
		int num_experiments = 6;
		int num_runs = 3;

		eng.putVariable("num_iterations", num_iterations);
		eng.putVariable("experimentType", experimentType);
		eng.putVariable("num_experiments", num_experiments);
		eng.putVariable("num_runs", num_runs);

		eng.putVariable("init", true);

		for (int i = 0; i < num_experiments; i++) {
			eng.putVariable("experiment", i+1);
			for (int j = 0; j < num_runs; j++) {
				eng.putVariable("experiment_run", j+1);

				eng.eval("clear params");
				eng.putVariable("isTraining", false);
				eng.eval("neat_network()");

				train(num_iterations, displayGameWindow);
			}
		}


		eng.putVariable("isVisualization", true);
		eng.eval("neat_network()");
		System.exit(0);

	}

	private static void train(int iterations, boolean displayGameWindow) throws Exception {
		IAgent agent = new Agent_NEAT();
		agent.receiveReward(MarioEnvironment.getInstance().getIntermediateReward());

		String options = FastOpts.LEVEL_04_BLOCKS + FastOpts.L_DIFFICULTY(4) + FastOpts.L_GAPS_ON + FastOpts.AI_RECEPTIVE_FIELD(15, 15);
		String visualizeON = FastOpts.VIS_ON_2X;
		String visualizeOFF = FastOpts.VIS_OFF;
		MarioSimulator simulator = new MarioSimulator(visualizeOFF + options);

		int maxNodeId = 0;
		eng.putVariable("isTraining", true);

		INDArray weightMatrixGlobalElite = null;
		int fitnessGlobalElite = 0;

		boolean isMultiLevelTraining = false;
		int[] trainingLevelSeeds = generateSeeds(1235, 50);
		int[] evaluationLevelSeeds = generateSeeds(12341234, 100);
		int levelSeedIndex = 0;
		for (int iteration = 0; iteration < iterations; iteration++) {

			System.out.println("iteration = " + iteration);
			eng.putVariable("iteration", iteration+1);

			((Agent_NEAT) agent).params = eng.getVariable("params");
			Object[] nodes = (Object[]) ((Agent_NEAT) agent).params.get("nodes");
			Object[] connections = (Object[]) ((Agent_NEAT) agent).params.get("connections");
			int num_networks = connections.length;
			int[] fitness = new int[connections.length];


			if (isMultiLevelTraining) {
				simulator = new MarioSimulator(visualizeOFF + FastOpts.L_RANDOM_SEED(trainingLevelSeeds[levelSeedIndex]) + options);
				if(iteration % 15 == 0) {
					if(levelSeedIndex < trainingLevelSeeds.length-1){
						//levelSeedIndex = ThreadLocalRandom.current().nextInt(0, trainingLevelSeeds.length-1);
						levelSeedIndex++;
					} else {
						levelSeedIndex = 0;
					}
				}
			}

			for (int currentNetworkId = 0; currentNetworkId < num_networks; currentNetworkId++) {

				INDArray nodesCurrent = Nd4j.create((double[][]) nodes[currentNetworkId]);
				INDArray connectionsCurrent = Nd4j.create((double[][]) connections[currentNetworkId]);

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

				boolean levelWon = MarioEnvironment.getInstance().getMario().sprite.mapX ==MarioEnvironment.getInstance().getLevelLength();
				if(levelWon)
				{
					fitness[currentNetworkId] = (int) MarioEnvironment.getInstance().getMario().sprite.x + MarioEnvironment.getInstance().getTimeLeft();
				} else {
					fitness[currentNetworkId] = (int) MarioEnvironment.getInstance().getMario().sprite.x;
				}
				if(fitness[currentNetworkId] >= fitnessGlobalElite) {
					fitnessGlobalElite = fitness[currentNetworkId];
					weightMatrixGlobalElite = ((Agent_NEAT) agent).weightMatrix;
				}


				//System.out.println("Fitness Pixel: "+fitness[currentNetworkId]+"\t max: "+ MarioEnvironment.getInstance().getLevelLength()*16 + "\t|\t Fitness Bloecke: " + MarioEnvironment.getInstance().getMario().sprite.mapX+"\t max: "+MarioEnvironment.getInstance().getLevelLength()+"\t| time left: "+MarioEnvironment.getInstance().getTimeLeft()+"\t\t| win?: "+ ((int) MarioEnvironment.getInstance().getMario().sprite.mapX ==(int) MarioEnvironment.getInstance().getLevelLength()?"True":"False"));

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

			if (displayGameWindow && (iteration == 0 || iteration % 500 == 0)) {
				simulator = new MarioSimulator(visualizeON + options + " " + MarioOptions.IntOption.SIMULATION_TIME_LIMIT.getParam() + " 100");
				((Agent_NEAT) agent).activation = Nd4j.zeros(1, weightMatrixGlobalElite.shape()[0]);
				((Agent_NEAT) agent).weightMatrix = weightMatrixGlobalElite;
				simulator.run(agent);
				simulator = new MarioSimulator(visualizeOFF + options);
			}

			eng.putVariable("marioFitness", fitness);
			eng.eval("neat_network()");

		}

		if (isMultiLevelTraining) {
			int[] validationFitness = new int[trainingLevelSeeds.length];
			for (int i = 0; i < trainingLevelSeeds.length; i++) {
				simulator = new MarioSimulator(visualizeOFF + FastOpts.L_RANDOM_SEED(trainingLevelSeeds[i]) + options);
				((Agent_NEAT) agent).activation = Nd4j.zeros(1, weightMatrixGlobalElite.shape()[0]);
				((Agent_NEAT) agent).weightMatrix = weightMatrixGlobalElite;
				simulator.run(agent);
				boolean levelWon = MarioEnvironment.getInstance().getMario().sprite.mapX ==MarioEnvironment.getInstance().getLevelLength();
				if(levelWon) {
					validationFitness[i] = (int) MarioEnvironment.getInstance().getMario().sprite.x + MarioEnvironment.getInstance().getTimeLeft();
				} else {
					validationFitness[i] = (int) MarioEnvironment.getInstance().getMario().sprite.x;
				}
			}
			eng.putVariable("validationFitness", validationFitness);
		}
	}

	public static int[] generateSeeds(int randomSeed, int count) {
		Random random = new Random(randomSeed);
		int[] seeds = new int[count];

		for (int i = 0; i < count; ++i) {
			seeds[i] = random.nextInt();
			while (seeds[i] <= 0) {
				seeds[i] += Integer.MAX_VALUE;
			}
		}

		return seeds;
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
